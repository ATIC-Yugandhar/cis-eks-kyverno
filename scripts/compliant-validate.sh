#!/bin/bash
set -euo pipefail

# Directories
COMPLIANT_DIR="terraform/compliant"
POLICY_DIR="kyverno-policies"
REPORT_DIR="reports/compliance"
TFPLAN_JSON="$COMPLIANT_DIR/tfplan.json"
KYVERNO_REPORT="$REPORT_DIR/kyverno-tfplan-report.yaml"

# Ensure report directory exists
mkdir -p "$REPORT_DIR"

# Deploy compliant stack
terraform -chdir="$COMPLIANT_DIR" init
terraform -chdir="$COMPLIANT_DIR" apply -auto-approve

# Generate tfplan.json
terraform -chdir="$COMPLIANT_DIR" show -json > "$TFPLAN_JSON"

# Run Kyverno CLI against tfplan.json with all policies
if ! command -v kyverno &> /dev/null; then
  echo "[ERROR] Kyverno CLI not found in PATH. Please install Kyverno CLI."
  exit 1
fi

kyverno apply "$POLICY_DIR"/*.yaml --resource "$TFPLAN_JSON" --output yaml > "$KYVERNO_REPORT"

echo "[INFO] Kyverno scan complete. Report saved to $KYVERNO_REPORT" 