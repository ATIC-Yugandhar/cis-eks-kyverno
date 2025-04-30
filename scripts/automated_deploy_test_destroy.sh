#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
# set -u # Temporarily disabled as it might cause issues if variables are conditionally set
# Pipestatus: exit status of the last command that threw a non-zero exit code is returned.
set -o pipefail

# --- Required AWS Permissions ---
# The following AWS permissions are typically required to execute this script successfully:
# - EC2: Create/Describe/Delete VPCs, Subnets, Security Groups, NAT Gateways, EC2 Instances (for nodes)
# - IAM: Create/Describe/Delete IAM Roles, Policies, Instance Profiles
# - EKS: Create/Describe/Delete EKS Clusters, Node Groups
# - S3: Create/Delete Buckets, Put/Get/Delete Objects (for Terraform backend)
# - DynamoDB: Create/Describe/Delete Tables (for Terraform state locking)
# - KMS: Describe/Create/Manage Keys (if using KMS encryption)
# Ensure the executing principal (user or role) has these permissions.

# --- Configuration Variables ---
# WARNING: Ensure AWS credentials are configured in your environment (e.g., via ~/.aws/credentials, environment variables, or IAM role).
# WARNING: Using terraform apply/destroy with -auto-approve is convenient for automation but risky. Understand the changes before running.

AWS_REGION="us-east-1" # Replace with your desired AWS region
BUCKET_NAME_SUFFIX=$(date +%s)-$(uuidgen | cut -d'-' -f1 | tr '[:upper:]' '[:lower:]') # Unique suffix for bucket name
BUCKET_NAME="tf-backend-eks-kyverno-${BUCKET_NAME_SUFFIX}"
DYNAMODB_TABLE_NAME="terraform-lock-eks-kyverno-${BUCKET_NAME_SUFFIX}"
COMPLIANT_CLUSTER_NAME="compliant-eks-cluster-${BUCKET_NAME_SUFFIX}"
NON_COMPLIANT_CLUSTER_NAME="non-compliant-eks-cluster-${BUCKET_NAME_SUFFIX}"
RESULTS_DIR="results_$(date +%Y%m%d_%H%M%S)"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(dirname "$SCRIPT_DIR")
TERRAFORM_DIR="$ROOT_DIR/terraform/examples/cluster"

# --- Cleanup Function ---
# This function attempts to destroy all potentially created resources.
cleanup() {
  echo "--- Running Cleanup ---"
  # Attempt to destroy Non-Compliant Cluster
  echo "Attempting to destroy Non-Compliant Cluster: $NON_COMPLIANT_CLUSTER_NAME"
  cd "$TERRAFORM_DIR" || { echo "Failed to cd to $TERRAFORM_DIR"; return 1; }
  # Try initializing first, might fail if backend wasn't setup, but destroy needs it
  if terraform init -input=false \
     -backend-config="bucket=$BUCKET_NAME" \
     -backend-config="key=examples/cluster-noncompliant.tfstate" \
     -backend-config="region=$AWS_REGION" \
     -backend-config="dynamodb_table=$DYNAMODB_TABLE_NAME"; then
      echo "Terraform initialized for Non-Compliant Cluster destroy."
      # Note: Terraform init output is not redirected to /dev/null here to aid debugging in case of errors during cleanup.
      terraform destroy -auto-approve -input=false \
        -var-file=noncompliant.tfvars \
        -var="cluster_name=$NON_COMPLIANT_CLUSTER_NAME" \
        -var="aws_region=$AWS_REGION" || echo "Warning: Failed to destroy Non-Compliant Cluster resources via Terraform. Manual cleanup might be required."
  else
      echo "Warning: Failed to initialize Terraform for Non-Compliant Cluster destroy. Skipping Terraform destroy."
  fi
  cd "$ROOT_DIR" || { echo "Failed to cd back to $ROOT_DIR"; return 1; } # Go back regardless
  echo "Non-Compliant Cluster destroy attempt finished."

  # Attempt to destroy Compliant Cluster
  echo "Attempting to destroy Compliant Cluster: $COMPLIANT_CLUSTER_NAME"
  cd "$TERRAFORM_DIR" || { echo "Failed to cd to $TERRAFORM_DIR"; return 1; }
  if terraform init -input=false \
     -backend-config="bucket=$BUCKET_NAME" \
     -backend-config="key=examples/cluster-compliant.tfstate" \
     -backend-config="region=$AWS_REGION" \
     -backend-config="dynamodb_table=$DYNAMODB_TABLE_NAME"; then
      echo "Terraform initialized for Compliant Cluster destroy."
      # Note: Terraform init output is not redirected to /dev/null here to aid debugging in case of errors during cleanup.
      terraform destroy -auto-approve -input=false \
        -var-file=compliant.tfvars \
        -var="cluster_name=$COMPLIANT_CLUSTER_NAME" \
        -var="aws_region=$AWS_REGION" || echo "Warning: Failed to destroy Compliant Cluster resources via Terraform. Manual cleanup might be required."
  else
      echo "Warning: Failed to initialize Terraform for Compliant Cluster destroy. Skipping Terraform destroy."
  fi
  cd "$ROOT_DIR" || { echo "Failed to cd back to $ROOT_DIR"; return 1; } # Go back regardless
  echo "Compliant Cluster destroy attempt finished."

  # Attempt to delete Backend Resources
  echo "Attempting to delete Terraform backend resources..."
  echo "Attempting to empty and delete S3 bucket: $BUCKET_NAME"
  aws s3 rb "s3://$BUCKET_NAME" --force --region "$AWS_REGION" || echo "Warning: Failed to delete S3 bucket $BUCKET_NAME. It might not exist or requires manual cleanup."

  echo "Attempting to delete DynamoDB table: $DYNAMODB_TABLE_NAME"
  aws dynamodb delete-table --table-name "$DYNAMODB_TABLE_NAME" --region "$AWS_REGION" || echo "Warning: Failed to delete DynamoDB table $DYNAMODB_TABLE_NAME. It might not exist or requires manual cleanup."

  echo "--- Cleanup Finished ---"
}

# --- Error Trap ---
# Call cleanup function if any command fails (non-zero exit status)
trap 'echo "An error occurred at line $LINENO. Running cleanup..."; cleanup; exit 1' ERR

# --- Main Function ---
main() {
  echo "--- Starting Automated Deployment, Test, and Destruction ---"

  # --- Prerequisites Check ---
  echo "Checking for required tools..."
  command -v aws >/dev/null || { echo >&2 "AWS CLI not found. Please install and configure it. Aborting."; exit 1; }
  command -v terraform >/dev/null || { echo >&2 "Terraform not found. Please install it. Aborting."; exit 1; }
  command -v kubectl >/dev/null || { echo >&2 "kubectl not found. Please install it. Aborting."; exit 1; }
  command -v helm >/dev/null || { echo >&2 "Helm not found. Please install it. Aborting."; exit 1; }
  command -v jq >/dev/null || { echo >&2 "jq not found. Please install it. Aborting."; exit 1; }
  echo "All required tools found."

  # --- Create Results Directory ---
  echo "Creating results directory: $ROOT_DIR/$RESULTS_DIR"
  mkdir -p "$ROOT_DIR/$RESULTS_DIR"

  # --- Setup Terraform Backend Resources ---
  echo "Setting up Terraform backend resources..."

  # Check and Create S3 Bucket
  echo "Checking for S3 bucket: $BUCKET_NAME"
  if ! aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" 2>/dev/null; then
    echo "S3 bucket not found. Creating bucket: $BUCKET_NAME in region $AWS_REGION..."
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
    echo "Enabling versioning for bucket $BUCKET_NAME..."
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
    echo "Enabling server-side encryption for bucket $BUCKET_NAME..."
    aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
    echo "S3 bucket $BUCKET_NAME created and configured."
  else
    echo "S3 bucket $BUCKET_NAME already exists."
  fi

  # Check and Create DynamoDB Table
  echo "Checking for DynamoDB table: $DYNAMODB_TABLE_NAME"
  if ! aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" --region "$AWS_REGION" 2>/dev/null; then
    echo "DynamoDB table not found. Creating table: $DYNAMODB_TABLE_NAME in region $AWS_REGION..."
    aws dynamodb create-table \
      --table-name "$DYNAMODB_TABLE_NAME" \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
      --region "$AWS_REGION"
    echo "Waiting for DynamoDB table $DYNAMODB_TABLE_NAME to become active..."
    aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE_NAME" --region "$AWS_REGION"
    echo "DynamoDB table $DYNAMODB_TABLE_NAME created."
  else
    echo "DynamoDB table $DYNAMODB_TABLE_NAME already exists."
  fi

  echo "Terraform backend resources setup complete."

  # --- Compliant Cluster Workflow ---
  # This section deploys a cluster intended to be compliant with the applied policies.
  # It uses 'compliant.tfvars' and a separate Terraform state file ('examples/cluster-compliant.tfstate')
  # to keep its infrastructure distinct from the non-compliant cluster.
  echo "Starting Compliant Cluster Workflow..."
  cd "$TERRAFORM_DIR" || { echo "Failed to cd to $TERRAFORM_DIR"; exit 1; }

  echo "Initializing Terraform for Compliant Cluster"
  terraform init -input=false \
    -backend-config="bucket=$BUCKET_NAME" \
    -backend-config="key=examples/cluster-compliant.tfstate" \
    -backend-config="region=$AWS_REGION" \
    -backend-config="dynamodb_table=$DYNAMODB_TABLE_NAME"

  echo "Applying Terraform configuration for Compliant Cluster (using compliant.tfvars)..."
  terraform apply -auto-approve -input=false \
    -var-file=compliant.tfvars \
    -var="cluster_name=$COMPLIANT_CLUSTER_NAME" \
    -var="aws_region=$AWS_REGION"

  echo "Updating kubeconfig for Compliant Cluster: $COMPLIANT_CLUSTER_NAME"
  aws eks update-kubeconfig --region "$AWS_REGION" --name "$COMPLIANT_CLUSTER_NAME"

  echo "Installing Kyverno Helm chart on Compliant Cluster..."
  # Add and update the Kyverno Helm repository. This only needs to be done once per script execution.
  helm repo add kyverno https://kyverno.github.io/kyverno/
  helm repo update
  helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set replicaCount=1 --set reports.enabled=true

  echo "Waiting for Kyverno pods to be ready on Compliant Cluster..."
  kubectl wait --for=condition=Ready pod -n kyverno --all --timeout=300s

  echo "Applying Kyverno CIS policies on Compliant Cluster..."
  kubectl apply -R -f "$ROOT_DIR/kyverno-policies/cis/"

  echo "Waiting for Kyverno ClusterPolicies to be ready on Compliant Cluster..."
  kubectl wait --for=condition=Ready clusterpolicy --all --timeout=120s || echo "Warning: Timed out waiting for all ClusterPolicies to become Ready. Continuing..."

  echo "Generating Policy Reports for Compliant Cluster..."
  kubectl get clusterpolicyreport -A -o wide > "$ROOT_DIR/$RESULTS_DIR/compliant_clusterpolicyreport.txt"
  kubectl get policyreport -A -o wide > "$ROOT_DIR/$RESULTS_DIR/compliant_policyreport.txt"

  echo "Compliant Cluster Workflow finished."
  cd "$ROOT_DIR" || { echo "Failed to cd back to $ROOT_DIR"; exit 1; }

  # --- Non-Compliant Cluster Workflow ---
  # This section deploys a cluster intended to demonstrate policy violations (non-compliance).
  # It uses 'noncompliant.tfvars' and a separate Terraform state file ('examples/cluster-noncompliant.tfstate')
  # to keep its infrastructure distinct from the compliant cluster.
  echo "Starting Non-Compliant Cluster Workflow..."
  cd "$TERRAFORM_DIR" || { echo "Failed to cd to $TERRAFORM_DIR"; exit 1; }

  echo "Initializing Terraform for Non-Compliant Cluster"
  terraform init -input=false \
    -backend-config="bucket=$BUCKET_NAME" \
    -backend-config="key=examples/cluster-noncompliant.tfstate" \
    -backend-config="region=$AWS_REGION" \
    -backend-config="dynamodb_table=$DYNAMODB_TABLE_NAME"

  echo "Applying Terraform configuration for Non-Compliant Cluster (using noncompliant.tfvars)..."
  terraform apply -auto-approve -input=false \
    -var-file=noncompliant.tfvars \
    -var="cluster_name=$NON_COMPLIANT_CLUSTER_NAME" \
    -var="aws_region=$AWS_REGION"

  echo "Updating kubeconfig for Non-Compliant Cluster: $NON_COMPLIANT_CLUSTER_NAME"
  aws eks update-kubeconfig --region "$AWS_REGION" --name "$NON_COMPLIANT_CLUSTER_NAME"

  echo "Installing Kyverno Helm chart on Non-Compliant Cluster..."
  # Assuming Helm repo is already added and updated
  helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set replicaCount=1 --set reports.enabled=true

  echo "Waiting for Kyverno pods to be ready on Non-Compliant Cluster..."
  kubectl wait --for=condition=Ready pod -n kyverno --all --timeout=300s

  echo "Applying Kyverno CIS policies on Non-Compliant Cluster..."
  kubectl apply -R -f "$ROOT_DIR/kyverno-policies/cis/"

  echo "Waiting for Kyverno ClusterPolicies to be ready on Non-Compliant Cluster..."
  kubectl wait --for=condition=Ready clusterpolicy --all --timeout=120s || echo "Warning: Timed out waiting for all ClusterPolicies to become Ready. Continuing..."

  echo "Generating Policy Reports for Non-Compliant Cluster..."
  kubectl get clusterpolicyreport -A -o wide > "$ROOT_DIR/$RESULTS_DIR/noncompliant_clusterpolicyreport.txt"
  kubectl get policyreport -A -o wide > "$ROOT_DIR/$RESULTS_DIR/noncompliant_policyreport.txt"

  echo "Non-Compliant Cluster Workflow finished."
  cd "$ROOT_DIR" || { echo "Failed to cd back to $ROOT_DIR"; exit 1; }

  # --- Normal Cleanup (Happy Path) ---
  # This runs only if the script completes without errors triggering the trap.
  echo "Script completed successfully. Running normal cleanup..."
  cleanup # Call the cleanup function for the normal teardown

  echo "--- Automated Deployment, Test, and Destruction Finished ---"
  echo "Script execution completed successfully. Results are in $ROOT_DIR/$RESULTS_DIR"
}

# --- Execute Main Function ---
main
