#!/bin/bash
set -euo pipefail

CLUSTER_TYPE="${1:-compliant}" # or "noncompliant"
TF_DIR="terraform/$CLUSTER_TYPE"
POLICY_DIR="kyverno-policies"
TEST_MANIFESTS_DIR="tests/$CLUSTER_TYPE"

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

echo "Deploying $CLUSTER_TYPE EKS cluster with Terraform..."
cd "$TF_DIR"
terraform init
terraform apply -auto-approve
cd - > /dev/null

REGION=$(terraform -chdir=$TF_DIR output -raw region)
CLUSTER_NAME=$(terraform -chdir=$TF_DIR output -raw cluster_name)

echo "Updating kubeconfig..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "Installing Kyverno policies..."
kubectl apply -f "$POLICY_DIR/"

echo "Applying test manifests for $CLUSTER_TYPE..."
kubectl apply -f "$TEST_MANIFESTS_DIR/"

echo "Waiting for Kyverno PolicyReports..."
sleep 30

echo "Kyverno PolicyReports:"
kubectl get policyreport,clusterpolicyreport -A -o yaml

echo "Done. Review PolicyReports above for compliance results." 