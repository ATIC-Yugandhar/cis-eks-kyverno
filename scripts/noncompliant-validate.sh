#!/bin/bash
set -euo pipefail

# Directories
NONCOMPLIANT_DIR="terraform/noncompliant"
POLICY_DIR="kyverno-policies"
REPORT_DIR="reports/compliance"
TFPLAN_JSON="$NONCOMPLIANT_DIR/tfplan.json"
KYVERNO_REPORT="$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"

# Ensure report directory exists
mkdir -p "$REPORT_DIR"

# Deploy noncompliant stack
terraform -chdir="$NONCOMPLIANT_DIR" init
terraform -chdir="$NONCOMPLIANT_DIR" apply -auto-approve

# Generate tfplan.json
terraform -chdir="$NONCOMPLIANT_DIR" show -json > "$TFPLAN_JSON"

# Run Kyverno CLI against tfplan.json with all policies
if ! command -v kyverno &> /dev/null; then
  echo "[ERROR] Kyverno CLI not found in PATH. Please install Kyverno CLI."
  exit 1
fi

kyverno apply "$POLICY_DIR"/*.yaml --resource "$TFPLAN_JSON" --output yaml > "$KYVERNO_REPORT"

echo "[INFO] Kyverno scan complete. Report saved to $KYVERNO_REPORT" 