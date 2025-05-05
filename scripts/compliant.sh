#!/bin/bash
set -euo pipefail

TF_DIR="terraform/compliant"
POLICY_DIR="kyverno-policies"
TEST_MANIFESTS_DIR="tests/compliant"

if [[ ! -d "$TF_DIR" ]]; then
  echo "[ERROR] Terraform directory $TF_DIR does not exist."
  exit 1
fi

if [[ ! -d "$POLICY_DIR" ]]; then
  echo "[ERROR] Kyverno policies directory $POLICY_DIR does not exist."
  exit 1
fi

if [[ ! -d "$TEST_MANIFESTS_DIR" ]]; then
  echo "[ERROR] Test manifests directory $TEST_MANIFESTS_DIR does not exist."
  exit 1
fi

echo "[INFO] Deploying compliant EKS cluster with Terraform..."
cd "$TF_DIR"
terraform init
terraform apply -auto-approve
cd - > /dev/null

REGION=$(terraform -chdir=$TF_DIR output -raw region)
CLUSTER_NAME=$(terraform -chdir=$TF_DIR output -raw cluster_name)

echo "[INFO] Updating kubeconfig..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo "[INFO] Waiting for nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Wait for Kyverno deployment to be ready
echo "[INFO] Waiting for Kyverno to be ready..."
kubectl rollout status deployment/kyverno -n kyverno --timeout=180s

# Apply Kyverno policies
echo "[INFO] Applying Kyverno policies..."
kubectl apply -f "$POLICY_DIR/"

# Apply compliant test manifests
if [ -d "$TEST_MANIFESTS_DIR" ]; then
  echo "[INFO] Applying compliant test manifests..."
  kubectl apply -f "$TEST_MANIFESTS_DIR/"
else
  echo "[WARN] No compliant test manifests directory found. Skipping."
fi

# Wait for PolicyReports to be generated
sleep 30

echo "[INFO] Kyverno PolicyReports:"
kubectl get policyreport,clusterpolicyreport -A -o yaml

echo "[INFO] Done. Review PolicyReports above for compliance results."