#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

if ! command -v kind &> /dev/null; then
  echo "Kind not found. Installing to ~/.local/bin..."
  INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$INSTALL_DIR"
  OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  curl -Lo "$INSTALL_DIR/kind" "https://kind.sigs.k8s.io/dl/latest/kind-${OS}-amd64"
  chmod +x "$INSTALL_DIR/kind"
  export PATH="$INSTALL_DIR:$PATH"
fi

# Check for yq
if ! command -v yq &> /dev/null; then
  echo "yq not found. Installing yq (version 4.40.5)..."
  # Adjust version and OS/ARCH as needed. This example is for macOS amd64.
  # For other systems, refer to: https://github.com/mikefarah/yq/#install
  YQ_VERSION="v4.40.5" # Specify a version
  YQ_BINARY="yq_darwin_amd64"
  if [[ "$(uname -s)" == "Linux" ]]; then
    YQ_BINARY="yq_linux_amd64"
  fi
  INSTALL_DIR_YQ="$HOME/.local/bin" # Can reuse the same for kind if desired
  mkdir -p "$INSTALL_DIR_YQ"
  curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}" -o "$INSTALL_DIR_YQ/yq"
  chmod +x "$INSTALL_DIR_YQ/yq"
  if ! [[ ":$PATH:" == *":$INSTALL_DIR_YQ:"* ]]; then # Add to PATH if not already there
    export PATH="$INSTALL_DIR_YQ:$PATH"
  fi
  echo "yq installed to $INSTALL_DIR_YQ/yq"
fi

kind create cluster --config "$SCRIPT_DIR/kind-cluster-config.yaml" --name demo

kubectl cluster-info

echo "Waiting for default service account to be available..."
until kubectl get serviceaccount default --context kind-demo &> /dev/null; do
  echo "Waiting for default service account..."
  sleep 2
done

echo "Applying namespace manifest..."
kubectl apply -f "$SCRIPT_DIR/manifests/namespace.yaml"

echo "Waiting for namespace to be available..."
until kubectl get namespace kyverno-aws &> /dev/null; do
  echo "Waiting for kyverno-aws namespace..."
  sleep 2
done

echo "Applying remaining application manifests..."
for file in "$SCRIPT_DIR"/manifests/*.yaml; do
  if [[ "$(basename "$file")" != "namespace.yaml" && "$(basename "$file")" != "kyverno-test.yaml" ]]; then
    kubectl apply -f "$file"
  fi
done

echo "Creating reports directory..."
mkdir -p "$SCRIPT_DIR/reports" # This line already existed, but instruction asked to ensure it.

REPORTS_DIR="$SCRIPT_DIR/reports"
KYVERNO_INSTALL_YAML="$REPORTS_DIR/kyverno-install.yaml"
mkdir -p "$REPORTS_DIR" # Explicitly creating as per instruction before download
echo "Downloading Kyverno v1.11.1 install.yaml to $KYVERNO_INSTALL_YAML..."
curl -L https://github.com/kyverno/kyverno/releases/download/v1.11.1/install.yaml -o "$KYVERNO_INSTALL_YAML" || { echo "Failed to download Kyverno install.yaml"; exit 1; }

echo "Installing Kyverno from $KYVERNO_INSTALL_YAML..."
kubectl create -f "$KYVERNO_INSTALL_YAML" || { echo "Failed to apply Kyverno install.yaml from $KYVERNO_INSTALL_YAML"; exit 1; }
echo "Kyverno install.yaml applied. Pausing for a few seconds for resources to be created..."
sleep 10 # Allow some time for CRDs to be registered by the API server
echo "Listing all CRDs in the cluster (grepping for kyverno):"
kubectl get crds | grep kyverno || echo "No Kyverno CRDs found yet."
echo "Waiting for ClusterPolicy CRD to be established..."
kubectl wait --for condition=established --timeout=120s crd/clusterpolicies.kyverno.io || { echo "ClusterPolicy CRD not established in time!"; exit 1; }
echo "Describing resources and scanning with Kyverno..."
bash "$SCRIPT_DIR/describe_resources.sh"
bash "$SCRIPT_DIR/run_kyverno.sh"

# Reports are now generated directly into the $SCRIPT_DIR/reports directory by sub-scripts.
# No need to move them anymore.

echo "Displaying Kyverno scan (cluster resources snapshot) report:"
cat "$SCRIPT_DIR/reports/kyverno_scan_cluster_resources_report.yaml" || echo "No Kyverno cluster scan report found (expected $SCRIPT_DIR/reports/kyverno_scan_cluster_resources_report.yaml)."

echo "Displaying Kyverno test (local manifests) report:"
# This report is now $SCRIPT_DIR/reports/kyverno_full_policies_apply_report.yaml (structured YAML)
# or $SCRIPT_DIR/reports/kyverno_full_policies_apply_stdout.txt (human-readable stdout)
echo "Displaying Kyverno test (local manifests) structured report:"
cat "$SCRIPT_DIR/reports/kyverno_full_policies_apply_report.yaml" || echo "No Kyverno local manifest structured test report found (expected $SCRIPT_DIR/reports/kyverno_full_policies_apply_report.yaml)."
echo "Displaying Kyverno test (local manifests) stdout report:"
cat "$SCRIPT_DIR/reports/kyverno_full_policies_apply_stdout.txt" || echo "No Kyverno local manifest stdout test report found (expected $SCRIPT_DIR/reports/kyverno_full_policies_apply_stdout.txt)."

echo "Cleaning up cluster..."
# bash "$SCRIPT_DIR/cleanup.sh"
