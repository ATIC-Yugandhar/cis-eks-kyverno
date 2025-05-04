#!/bin/bash
set -euo pipefail

# Paths
POLICY_DIR="kyverno-policies"
SAMPLE_MANIFEST="docs/sample-eks.yaml"
LOCAL_REPORT="docs/compliance-local.md"
COMPLIANT_DIR="terraform/compliant"
COMPLIANT_REPORT="docs/compliance-report-compliant.md"

echo "# Local Kyverno Validation" > "$LOCAL_REPORT"
echo '```' >> "$LOCAL_REPORT"
for policy in "$POLICY_DIR"/*.yaml; do
  echo "Validating policy: $policy" >> "$LOCAL_REPORT"
  kyverno apply "$policy" --resource "$SAMPLE_MANIFEST" >> "$LOCAL_REPORT" 2>&1 || true
  echo "" >> "$LOCAL_REPORT"
done
echo '```' >> "$LOCAL_REPORT"

# Provision compliant cluster
echo "Provisioning compliant cluster..."
cd "$COMPLIANT_DIR"
terraform init -input=false
terraform apply -auto-approve
cd - > /dev/null

# Deploy Kyverno controller to the cluster (using Helm)
echo "Deploying Kyverno controller to cluster..."
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
echo "# Compliance Scan Report" > "$COMPLIANT_REPORT"
echo '```' >> "$COMPLIANT_REPORT"
kyverno report > "$COMPLIANT_REPORT" 2>&1 || true
echo '```' >> "$COMPLIANT_REPORT"

echo "Compliant automation complete. Reports generated:"
echo "  - $LOCAL_REPORT"
echo "  - $COMPLIANT_REPORT"