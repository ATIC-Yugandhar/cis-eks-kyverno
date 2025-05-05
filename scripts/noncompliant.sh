#!/bin/bash
set -euo pipefail

# Determine script root
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "$dir/.." && pwd)"

# Paths
POLICY_DIR="$root_dir/kyverno-policies"
SAMPLE_MANIFEST="$root_dir/docs/sample-eks.yaml"
NONCOMPLIANT_DIR="$root_dir/terraform/noncompliant"
NONCOMPLIANT_REPORT="$root_dir/docs/compliance-report-noncompliant.md"

# Provision non-compliant cluster if Terraform code changed
echo "Provisioning non-compliant cluster (if needed)..."
cd "$NONCOMPLIANT_DIR"
if git diff --quiet . && git diff --cached --quiet .; then
  echo "[SKIP] No Terraform code changes detected."
else
  terraform init -input=false
  echo "Checking for Terraform changes..."
  PLAN_OUTPUT=$(terraform plan -no-color)
  if echo "$PLAN_OUTPUT" | grep -q "No changes. Infrastructure is up-to-date."; then
    echo "[SKIP] Remote infrastructure is already up-to-date."
  else
    terraform apply -auto-approve
  fi
fi

# Capture cluster info
echo "Fetching cluster details..."
REGION=$(terraform output -raw region)
CLUSTER_NAME=$(terraform output -raw cluster_name)
cd - > /dev/null

# Update Kubernetes config
echo "Updating Kubernetes config for $CLUSTER_NAME in $REGION..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

# Wait for cluster to become reachable
echo "Waiting for cluster to become reachable..."
max_wait=600 # seconds
start_time=$(date +%s)
success=false
while (( $(date +%s) - start_time < max_wait )); do
    if kubectl cluster-info > /dev/null 2>&1; then
        success=true
        break
    fi
    echo -n "."
    sleep 15
done
if [ "$success" = false ]; then
    echo "Cluster not reachable after timeout. Exiting."
    exit 1
fi

# Deploy Kyverno controller
echo "Deploying Kyverno controller to cluster..."
if ! command -v helm >/dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
kubectl create namespace kyverno || true
helm repo add kyverno https://kyverno.github.io/kyverno/ || true
helm repo update
helm upgrade --install kyverno kyverno/kyverno -n kyverno

# Apply all Kyverno policies
echo "Applying Kyverno policies..."
for policy in "$POLICY_DIR"/*.yaml; do
    kubectl apply -f "$policy"
done

# Deploy test workloads
echo "Deploying test workloads from $SAMPLE_MANIFEST..."
kubectl apply -f "$SAMPLE_MANIFEST"

# Run compliance scan against live cluster resources
echo "Generating compliance report..."
printf "# Compliance Scan Report\n\`\`\`\n" > "$NONCOMPLIANT_REPORT"
kyverno report >> "$NONCOMPLIANT_REPORT" 2>&1 || true
printf "\`\`\`\n" >> "$NONCOMPLIANT_REPORT"

# Validate expected policy violations in report
if ! grep -q -i 'fail' "$NONCOMPLIANT_REPORT"; then
  echo "[ERROR] No policy violations detected; expected noncompliant result."
  exit 1
fi

# Done
echo "Noncompliant automation complete. Report generated: $NONCOMPLIANT_REPORT"