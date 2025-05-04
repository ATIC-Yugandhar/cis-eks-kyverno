#!/bin/bash
set -euo pipefail

# Determine script root
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "$dir/.." && pwd)"

# Paths
POLICY_DIR="$root_dir/kyverno-policies"
SAMPLE_MANIFEST="$root_dir/docs/sample-eks.yaml"
COMPLIANT_DIR="$root_dir/terraform/compliant"
COMPLIANT_REPORT="$root_dir/docs/compliance-report-compliant.md"
BASTION_USER="ubuntu"
SSH_KEY="$COMPLIANT_DIR/bastion_key.pem"

# Provision compliant cluster (if not already running)
echo "Provisioning compliant cluster (if needed)..."
cd "$COMPLIANT_DIR"

# Only run Terraform when local Terraform code has changed
if git diff --quiet . && git diff --cached --quiet .; then
  echo "[SKIP] No Terraform code changes detected locally. Skipping plan/apply."
else
  terraform init -input=false
  echo "Checking for Terraform changes..."
  PLAN_OUTPUT=$(terraform plan -no-color)
  if echo "$PLAN_OUTPUT" | grep -q "No changes. Infrastructure is up-to-date."; then
    echo "[SKIP] Remote infrastructure is already up-to-date."
  else
    echo "Changes detected. Running 'terraform apply'..."
    terraform apply -auto-approve
  fi
fi

BASTION_IP=$(terraform output -raw bastion_public_ip)
cd - > /dev/null

# Wait for bastion host to be SSH-ready
echo "Waiting for bastion host ($BASTION_IP) to become SSH-ready..."
max_retries=12
retry_count=0
while [ $retry_count -lt $max_retries ]; do
  if ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$BASTION_USER@$BASTION_IP" exit 2>/dev/null; then
    echo "Bastion host is ready."
    break
  fi
  retry_count=$((retry_count + 1))
  echo "Attempt $retry_count/$max_retries failed. Retrying in 10 seconds..."
  sleep 10
done

if [ $retry_count -eq $max_retries ]; then
  echo "Error: Bastion host did not become SSH-ready after $max_retries attempts."
  exit 1
fi

# Copy policies and manifests to bastion
echo "Checking if files need to be copied to bastion..."

declare -a files_to_copy=()

# Function to check file hash on bastion
check_remote_hash() {
  local local_file="$1"
  local remote_file="$2"
  local local_hash
  local remote_hash

  if [ -d "$local_file" ]; then
    # Directory: check all files recursively
    find "$local_file" -type f | while read -r f; do
      rel_path="${f#$local_file/}"
      remote_path="~/$remote_file/$rel_path"
      local_hash=$(sha256sum "$f" | awk '{print $1}')
      remote_hash=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$BASTION_USER@$BASTION_IP" "sha256sum $remote_path 2>/dev/null | awk '{print \$1}'" || echo "MISSING")
      if [ "$local_hash" != "$remote_hash" ]; then
        echo "[COPY] $f differs from $remote_path"
        copy_needed=1
        return 1
      fi
    done
  else
    local_hash=$(sha256sum "$local_file" | awk '{print $1}')
    remote_hash=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$BASTION_USER@$BASTION_IP" "sha256sum ~/$remote_file 2>/dev/null | awk '{print \$1}'" || echo "MISSING")
    if [ "$local_hash" != "$remote_hash" ]; then
      echo "[COPY] $local_file differs from ~/$remote_file"
      copy_needed=1
      return 1
    fi
  fi
  return 0
}

# Check differences without exiting on error
set +e
check_remote_hash "$POLICY_DIR" "$POLICY_DIR"
if [ $? -ne 0 ]; then files_to_copy+=("$POLICY_DIR"); fi

check_remote_hash "$SAMPLE_MANIFEST" "$(basename "$SAMPLE_MANIFEST")"
if [ $? -ne 0 ]; then files_to_copy+=("$SAMPLE_MANIFEST"); fi
set -e

if [ ${#files_to_copy[@]} -eq 0 ]; then
  echo "[SKIP] All files already exist and match on bastion. Skipping copy."
else
  echo "Copying changed files to bastion: ${files_to_copy[*]}"
  scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -r "${files_to_copy[@]}" "$BASTION_USER@$BASTION_IP:~/"
fi

# Determine cluster region and name locally
disable_exit=false
LOCAL_REGION=$(cd "$COMPLIANT_DIR" && terraform output -raw region)
LOCAL_CLUSTER=$(cd "$COMPLIANT_DIR" && terraform output -raw cluster_name)

# Run remote compliance workflow on bastion
echo "Running compliance workflow on bastion..."

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$BASTION_USER@$BASTION_IP" bash -s <<EOF
set -euo pipefail

# Set environment for AWS CLI
export REGION="$LOCAL_REGION"
export CLUSTER_NAME="$LOCAL_CLUSTER"

# Install AWS CLI, kubectl, and Kyverno CLI if not present
if ! command -v aws >/dev/null; then
  sudo apt-get update
  sudo apt-get install -y awscli
fi
if ! command -v kubectl >/dev/null; then
  K8S_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
  if [ -z "$K8S_VERSION" ]; then
    echo "Error: Failed to fetch latest Kubernetes version. Aborting kubectl installation."
    exit 1
  fi
  # Validate version string (should start with 'v' and contain only allowed chars)
  if ! [[ "$K8S_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo "Error: Invalid Kubernetes version string: $K8S_VERSION"
    exit 1
  fi
  KUBECTL_URL="https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
  # Check URL format
  if [[ ! "$KUBECTL_URL" =~ ^https://dl\.k8s\.io/release/v[0-9]+\.[0-9]+\.[0-9]+/bin/linux/amd64/kubectl$ ]]; then
    echo "Error: Constructed kubectl URL is invalid: $KUBECTL_URL"
    exit 1
  fi
  if ! curl -LO -f -L "$KUBECTL_URL"; then
    echo "Error: Failed to download kubectl from $KUBECTL_URL"
    exit 1
  fi
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
fi
if ! command -v kyverno >/dev/null; then
  echo "[INFO] Kyverno CLI not found. Installing via direct binary installation..."
  KYVERNO_VERSION=$(curl -s https://api.github.com/repos/kyverno/kyverno/releases/latest | grep '"tag_name"' | head -n1 | cut -d '"' -f4)
  KYVERNO_URL="https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/kyverno-cli_${KYVERNO_VERSION}_linux_x86_64.tar.gz"
  curl -L -o kyverno.tar.gz "$KYVERNO_URL"
  tar -zxvf kyverno.tar.gz
  chmod +x kyverno
  sudo mv kyverno /usr/local/bin/kyverno
  rm kyverno.tar.gz
fi

# Set up kubeconfig
# Removed remote Terraform lookups
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

# Wait for cluster to become reachable
echo "Waiting for cluster to become reachable..."
max_wait=600
start_time=\$(date +%s)
success=false
while [[ \$(( \$(date +%s) - \$start_time )) -lt \$max_wait ]]; do
    if kubectl cluster-info > /dev/null 2>&1; then
        success=true
        break
    fi
    echo -n "."
    sleep 15
done
if [ "\$success" = false ]; then
    echo "Cluster not reachable after timeout. Exiting."
    exit 1
fi

# Deploy Kyverno controller (using Helm)
if ! command -v helm >/dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
kubectl create namespace kyverno || true
helm repo add kyverno https://kyverno.github.io/kyverno/ || true
helm repo update
helm upgrade --install kyverno kyverno/kyverno -n kyverno

# Apply all Kyverno policies
echo "Applying Kyverno policies..."
for policy in kyverno-policies/*.yaml; do
    kubectl apply -f "\$policy"
done

# Deploy test workloads
echo "Deploying test workloads from docs/sample-eks.yaml..."
kubectl apply -f docs/sample-eks.yaml

# Run compliance scan
echo "# Compliance Scan Report" > compliance-report-compliant.md
echo '```' >> compliance-report-compliant.md
kyverno report >> compliance-report-compliant.md 2>&1 || true
echo '```' >> compliance-report-compliant.md

EOF

# Copy compliance report back to local machine
echo "Copying compliance report from bastion..."
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$BASTION_USER@$BASTION_IP:~/compliance-report-compliant.md" "$COMPLIANT_REPORT"

echo "Compliant automation complete. Report generated:"
echo "  - $COMPLIANT_REPORT"

echo ""
echo "Manual steps required:"
echo "1. The SSH key is generated automatically at terraform/compliant/bastion_key.pem and used by this script."
echo "2. Ensure AWS credentials are available on the bastion (via IAM role or aws configure)."
echo "3. If you need to re-run, ensure policies and manifests are up to date on the bastion."