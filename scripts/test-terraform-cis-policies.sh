#!/bin/bash
set -euo pipefail

# Enable Kyverno experimental features for Terraform plan scanning
export KYVERNO_EXPERIMENTAL=true

# Set base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

# Verify kyverno CLI is installed
if ! command -v kyverno &> /dev/null; then
  echo "ERROR: Kyverno CLI not found. Please make sure it's installed."
  exit 1
fi

echo "Using Kyverno CLI: $(which kyverno)"
echo "Kyverno version: $(kyverno version)"

# Directories
COMPLIANT_DIR="${BASE_DIR}/terraform/compliant"
NONCOMPLIANT_DIR="${BASE_DIR}/terraform/noncompliant"
POLICY_DIR="${BASE_DIR}/kyverno-policies/terraform"
REPORT_DIR="${BASE_DIR}/reports/compliance"

echo "Verifying directories:"
echo "COMPLIANT_DIR: ${COMPLIANT_DIR}"
echo "NONCOMPLIANT_DIR: ${NONCOMPLIANT_DIR}"
echo "POLICY_DIR: ${POLICY_DIR}"
echo "REPORT_DIR: ${REPORT_DIR}"

if [ ! -d "$POLICY_DIR" ]; then
  echo "ERROR: Policy directory not found: $POLICY_DIR"
  # Check if it exists at a different location
  POLICY_FILES=$(find "${BASE_DIR}" -path "*/terraform/*.yaml")
  if [ -n "$POLICY_FILES" ]; then
    FIRST_POLICY=$(echo "$POLICY_FILES" | head -1)
    POLICY_DIR=$(dirname "$FIRST_POLICY")
    echo "Found policy files in $POLICY_DIR instead, using this directory."
  else
    echo "No terraform policy files found in the repository."
    exit 1
  fi
fi

mkdir -p "$REPORT_DIR"

# Generate tfplan.json for compliant
echo "Initializing Terraform in compliant directory: $COMPLIANT_DIR"
terraform -chdir="$COMPLIANT_DIR" init -input=false
echo "[INFO] Planning compliant stack..."
terraform -chdir="$COMPLIANT_DIR" plan -out=tfplan.binary -input=false
rm -rf "$COMPLIANT_DIR/tfplan.json"
terraform -chdir="$COMPLIANT_DIR" show -json tfplan.binary > "$COMPLIANT_DIR/tfplan.json"

# Test compliant plan
# Scan compliant plan with all policies
: > "$REPORT_DIR/kyverno-tfplan-report.yaml"
echo "Looking for policy files in: $POLICY_DIR"
POLICY_FILES=$(find "$POLICY_DIR" -type f -name "*.yaml" | sort)
if [ -z "$POLICY_FILES" ]; then
  echo "WARNING: No policy files found in $POLICY_DIR"
  # Try finding files in alternative locations
  echo "Searching for terraform policy files in alternative locations..."
  POLICY_FILES=$(find "${BASE_DIR}" -path "*/terraform/*.yaml" | sort)
fi

echo "Found policy files:"
echo "$POLICY_FILES"

for policy in $POLICY_FILES; do
  echo "[INFO] Scanning $policy against compliant tfplan.json" | tee -a "$REPORT_DIR/kyverno-tfplan-report.yaml"
  kyverno json scan --policy "$policy" --payload "$COMPLIANT_DIR/tfplan.json" >> "$REPORT_DIR/kyverno-tfplan-report.yaml" 2>&1 || true
  echo "" >> "$REPORT_DIR/kyverno-tfplan-report.yaml"
done
echo "[INFO] Compliant plan results written to $REPORT_DIR/kyverno-tfplan-report.yaml"

# Generate tfplan.json for noncompliant
echo "Initializing Terraform in noncompliant directory: $NONCOMPLIANT_DIR"
terraform -chdir="$NONCOMPLIANT_DIR" init -input=false
echo "[INFO] Planning noncompliant stack..."
terraform -chdir="$NONCOMPLIANT_DIR" plan -out=tfplan.binary -input=false
rm -rf "$NONCOMPLIANT_DIR/tfplan.json"
terraform -chdir="$NONCOMPLIANT_DIR" show -json tfplan.binary > "$NONCOMPLIANT_DIR/tfplan.json"

# Test noncompliant plan
# Scan noncompliant plan with all policies
: > "$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"
for policy in $POLICY_FILES; do
  echo "[INFO] Scanning $policy against noncompliant tfplan.json" | tee -a "$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"
  kyverno json scan --policy "$policy" --payload "$NONCOMPLIANT_DIR/tfplan.json" >> "$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml" 2>&1 || true
  echo "" >> "$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"
done
echo "[INFO] Noncompliant plan results written to $REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"