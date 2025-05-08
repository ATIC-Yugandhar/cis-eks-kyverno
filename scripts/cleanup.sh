#!/bin/bash
set -euo pipefail

# Destroy compliant resources
if [ -d "terraform/compliant" ]; then
  echo "[INFO] Destroying compliant stack..."
  terraform -chdir=terraform/compliant destroy -auto-approve || true
fi

# Destroy noncompliant resources
if [ -d "terraform/noncompliant" ]; then
  echo "[INFO] Destroying noncompliant stack..."
  terraform -chdir=terraform/noncompliant destroy -auto-approve || true
fi

# Optionally, delete any S3 buckets created by the repo (automation buckets, etc.)
# Uncomment the following lines if you want to force-delete S3 buckets (be careful!)
# for BUCKET in $(aws s3 ls | awk '/eks-kyverno-automation-/ {print $3}'); do
#   echo "[INFO] Deleting S3 bucket: $BUCKET"
#   aws s3 rb s3://$BUCKET --force || true
# done

echo "[INFO] Cleanup complete." 