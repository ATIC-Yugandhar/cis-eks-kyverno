#!/bin/bash
set -euo pipefail

# Directories
COMPLIANT_DIR="terraform/compliant"
NONCOMPLIANT_DIR="terraform/noncompliant"
POLICY_DIR="kyverno-policies/terraform"
REPORT_DIR="reports/compliance"

mkdir -p "$REPORT_DIR"

# Generate tfplan.json for compliant
terraform -chdir="$COMPLIANT_DIR" init -input=false
echo "[INFO] Planning compliant stack..."
terraform -chdir="$COMPLIANT_DIR" plan -out=tfplan.binary -input=false
terraform -chdir="$COMPLIANT_DIR" show -json tfplan.binary > "$COMPLIANT_DIR/tfplan.json"

# Test compliant plan
kyverno-json scan --payload "$COMPLIANT_DIR/tfplan.json" --policy "$POLICY_DIR" > "$REPORT_DIR/kyverno-tfplan-report.yaml"
echo "[INFO] Compliant plan results written to $REPORT_DIR/kyverno-tfplan-report.yaml"

# Generate tfplan.json for noncompliant
terraform -chdir="$NONCOMPLIANT_DIR" init -input=false
echo "[INFO] Planning noncompliant stack..."
terraform -chdir="$NONCOMPLIANT_DIR" plan -out=tfplan.binary -input=false
terraform -chdir="$NONCOMPLIANT_DIR" show -json tfplan.binary > "$NONCOMPLIANT_DIR/tfplan.json"

# Test noncompliant plan
kyverno-json scan --payload "$NONCOMPLIANT_DIR/tfplan.json" --policy "$POLICY_DIR" > "$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"
echo "[INFO] Noncompliant plan results written to $REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml" 