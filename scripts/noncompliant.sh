#!/bin/bash
set -euo pipefail

# Paths
POLICY_DIR="kyverno-policies"
SAMPLE_MANIFEST="docs/sample-eks.yaml"
LOCAL_REPORT="docs/compliance-local.md"
NONCOMPLIANT_DIR="terraform/noncompliant"
NONCOMPLIANT_REPORT="docs/compliance-report-noncompliant.md"

# Provision non-compliant cluster
echo "Provisioning non-compliant cluster..."
cd "$NONCOMPLIANT_DIR"
terraform init -input=false
terraform apply -auto-approve
cd - > /dev/null

# Update Kubernetes config
echo "Updating Kubernetes config..."
aws eks update-kubeconfig --name noncompliant-eks-cluster --region us-west-2

# Wait for cluster to become reachable
echo "Waiting for cluster to become reachable..."
max_wait=600 # 10 minutes
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
echo "# Compliance Scan Report" > "$NONCOMPLIANT_REPORT"
echo '```' >> "$NONCOMPLIANT_REPORT"
kyverno report > "$NONCOMPLIANT_REPORT" 2>&1 || true
echo '```' >> "$NONCOMPLIANT_REPORT"

echo "Noncompliant automation complete. Reports generated:"
echo "  - $LOCAL_REPORT"
echo "  - $NONCOMPLIANT_REPORT"