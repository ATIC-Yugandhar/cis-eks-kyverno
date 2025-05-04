#!/bin/bash
set -euo pipefail

# Paths
COMPLIANT_DIR="terraform/compliant"
NONCOMPLIANT_DIR="terraform/noncompliant"
POLICY_DIR="kyverno-policies"
REPORT_DIR="docs"
COMPLIANT_REPORT="$REPORT_DIR/compliance-report-compliant.md"
NONCOMPLIANT_REPORT="$REPORT_DIR/compliance-report-noncompliant.md"
BLOG_REPORT="$REPORT_DIR/compliance-comparison-blog.md"

# Helper to switch kubeconfig context
function set_kubeconfig() {
  export KUBECONFIG="$1"
}

# Cleanup function to destroy both clusters
function cleanup_clusters() {
  echo "Destroying compliant EKS cluster (if exists)..."
  cd "$COMPLIANT_DIR"
  terraform destroy -auto-approve -input=false || true
  cd - >/dev/null
  echo "Destroying noncompliant EKS cluster (if exists)..."
  cd "$NONCOMPLIANT_DIR"
  terraform destroy -auto-approve -input=false || true
  cd - >/dev/null
}

# Trap to ensure cleanup on error or exit
trap cleanup_clusters EXIT

# Function to apply policies and run scan
function run_kyverno_scan() {
  local KUBECONFIG_PATH="$1"
  local REPORT_PATH="$2"
  local CLUSTER_LABEL="$3"

  set_kubeconfig "$KUBECONFIG_PATH"

  echo "Deploying Kyverno to $CLUSTER_LABEL cluster..."
  kubectl create namespace kyverno --dry-run=client -o yaml | kubectl apply -f -
  kubectl apply -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/release/install.yaml

  echo "Waiting for Kyverno pods to be ready in $CLUSTER_LABEL cluster..."
  kubectl rollout status deployment/kyverno -n kyverno --timeout=180s

  echo "Applying Kyverno policies to $CLUSTER_LABEL cluster..."
  for policy in $POLICY_DIR/*.yaml; do
    kubectl apply -f "$policy"
  done

  echo "Running Kyverno compliance scan on $CLUSTER_LABEL cluster..."
  kyverno apply $POLICY_DIR/*.yaml --cluster --output json > kyverno-results-$CLUSTER_LABEL.json

  echo "Generating compliance report for $CLUSTER_LABEL cluster..."
  PASSED=$(jq '[.[] | select(.status=="pass")] | length' kyverno-results-$CLUSTER_LABEL.json)
  FAILED=$(jq '[.[] | select(.status=="fail")] | length' kyverno-results-$CLUSTER_LABEL.json)
  TOTAL=$((PASSED + FAILED))
  SCORE=0
  if [ "$TOTAL" -gt 0 ]; then
    SCORE=$((100 * PASSED / TOTAL))
  fi

  {
    echo "# Compliance Report for $CLUSTER_LABEL Cluster"
    echo ""
    echo "**Compliance Score:** $SCORE%"
    echo ""
    echo "| CIS Control | Status |"
    echo "|-------------|--------|"
    jq -r '.[] | "| \(.policy) | \(.status | ascii_upcase) |"' kyverno-results-$CLUSTER_LABEL.json
  } > "$REPORT_PATH"
}

# --- Step 1: Compliant Cluster ---
echo "Provisioning compliant EKS cluster..."
cd "$COMPLIANT_DIR"
terraform init -input=false
terraform apply -auto-approve -input=false

# Generate kubeconfig for compliant cluster
COMPLIANT_CLUSTER_NAME="$(terraform output -raw cluster_name)"
COMPLIANT_REGION="$(terraform output -raw region 2>/dev/null || echo "us-west-2")"
aws eks update-kubeconfig --name "$COMPLIANT_CLUSTER_NAME" --region "$COMPLIANT_REGION"
cd - >/dev/null

# Wait for kubeconfig file to exist (timeout 120s)
echo "Waiting for kubeconfig file for compliant cluster: ~/.kube/config"
for i in {1..24}; do
  if [ -f "$HOME/.kube/config" ]; then
    break
  fi
  sleep 5
done
if [ ! -f "$HOME/.kube/config" ]; then
  echo "ERROR: kubeconfig file for compliant cluster not found: ~/.kube/config"
  exit 1
fi

run_kyverno_scan "$HOME/.kube/config" "$COMPLIANT_REPORT" "Compliant"

# Verify Kyverno scan output and report
if [ ! -f "kyverno-results-Compliant.json" ]; then
  echo "ERROR: Kyverno scan output for compliant cluster missing."
  exit 1
fi
if [ ! -f "$COMPLIANT_REPORT" ]; then
  echo "ERROR: Compliance report for compliant cluster missing."
  exit 1
fi

echo "Destroying compliant EKS cluster..."
cd "$COMPLIANT_DIR"
terraform destroy -auto-approve -input=false
cd - >/dev/null

# --- Step 2: Noncompliant Cluster ---
echo "Provisioning noncompliant EKS cluster..."
cd "$NONCOMPLIANT_DIR"
terraform init -input=false
terraform apply -auto-approve -input=false

# Generate kubeconfig for noncompliant cluster
NONCOMPLIANT_CLUSTER_NAME="$(terraform output -raw cluster_name)"
NONCOMPLIANT_REGION="$(terraform output -raw region 2>/dev/null || echo "us-west-2")"
aws eks update-kubeconfig --name "$NONCOMPLIANT_CLUSTER_NAME" --region "$NONCOMPLIANT_REGION"
cd - >/dev/null

# Wait for kubeconfig file to exist (timeout 120s)
echo "Waiting for kubeconfig file for noncompliant cluster: ~/.kube/config"
for i in {1..24}; do
  if [ -f "$HOME/.kube/config" ]; then
    break
  fi
  sleep 5
done
if [ ! -f "$HOME/.kube/config" ]; then
  echo "ERROR: kubeconfig file for noncompliant cluster not found: ~/.kube/config"
  exit 1
fi

run_kyverno_scan "$HOME/.kube/config" "$NONCOMPLIANT_REPORT" "Noncompliant"

# Verify Kyverno scan output and report
if [ ! -f "kyverno-results-Noncompliant.json" ]; then
  echo "ERROR: Kyverno scan output for noncompliant cluster missing."
  exit 1
fi
if [ ! -f "$NONCOMPLIANT_REPORT" ]; then
  echo "ERROR: Compliance report for noncompliant cluster missing."
  exit 1
fi

echo "Destroying noncompliant EKS cluster..."
cd "$NONCOMPLIANT_DIR"
terraform destroy -auto-approve -input=false
cd - >/dev/null

# --- Step 3: Compare and Blog ---
echo "Comparing compliance results and writing blog report..."
{
  echo "# Kyverno Compliance Comparison: Compliant vs Noncompliant EKS Clusters"
  echo ""
  echo "## Compliance Scores"
  echo ""
  COMPLIANT_SCORE=$(grep -oP '\*\*Compliance Score:\*\* \K[0-9]+%' "$COMPLIANT_REPORT" | head -1)
  NONCOMPLIANT_SCORE=$(grep -oP '\*\*Compliance Score:\*\* \K[0-9]+%' "$NONCOMPLIANT_REPORT" | head -1)
  echo "- **Compliant Cluster:** $COMPLIANT_SCORE"
  echo "- **Noncompliant Cluster:** $NONCOMPLIANT_SCORE"
  echo ""
  echo "## Detailed Results"
  echo ""
  echo "### Compliant Cluster"
  tail -n +1 "$COMPLIANT_REPORT"
  echo ""
  echo "### Noncompliant Cluster"
  tail -n +1 "$NONCOMPLIANT_REPORT"
  echo ""
  echo "## Observations"
  echo ""
  echo "- The compliant cluster should have a higher compliance score and more CIS controls passing."
  echo "- Review the failed controls in the noncompliant cluster for remediation opportunities."
} > "$BLOG_REPORT"

echo "All steps complete. Reports generated at:"
echo "  $COMPLIANT_REPORT"
echo "  $NONCOMPLIANT_REPORT"
echo "  $BLOG_REPORT"