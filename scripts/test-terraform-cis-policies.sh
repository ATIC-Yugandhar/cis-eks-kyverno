#!/bin/bash
set -euo pipefail

# Enable Kyverno experimental features for Terraform plan scanning
export KYVERNO_EXPERIMENTAL=true

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
rm -rf "$COMPLIANT_DIR/tfplan.json"
terraform -chdir="$COMPLIANT_DIR" show -json tfplan.binary > "$COMPLIANT_DIR/tfplan.json"

# Test compliant plan
# Scan compliant plan with all policies
: > "$REPORT_DIR/kyverno-tfplan-report.yaml"
for policy in "$POLICY_DIR"/*.yaml; do
  echo "[INFO] Scanning $policy against compliant tfplan.json" >> "$REPORT_DIR/kyverno-tfplan-report.yaml"
  kyverno json scan --policy "$policy" --payload "$COMPLIANT_DIR/tfplan.json" >> "$REPORT_DIR/kyverno-tfplan-report.yaml" 2>&1
  echo "" >> "$REPORT_DIR/kyverno-tfplan-report.yaml"
done
echo "[INFO] Compliant plan results written to $REPORT_DIR/kyverno-tfplan-report.yaml"

# Generate tfplan.json for noncompliant
terraform -chdir="$NONCOMPLIANT_DIR" init -input=false
echo "[INFO] Planning noncompliant stack..."
terraform -chdir="$NONCOMPLIANT_DIR" plan -out=tfplan.binary -input=false
rm -rf "$NONCOMPLIANT_DIR/tfplan.json"
terraform -chdir="$NONCOMPLIANT_DIR" show -json tfplan.binary > "$NONCOMPLIANT_DIR/tfplan.json"

# Test noncompliant plan
# Scan noncompliant plan with all policies
: > "$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"
for policy in "$POLICY_DIR"/*.yaml; do
  echo "[INFO] Scanning $policy against noncompliant tfplan.json" >> "$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"
  kyverno json scan --policy "$policy" --payload "$NONCOMPLIANT_DIR/tfplan.json" >> "$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml" 2>&1
  echo "" >> "$REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"
done
echo "[INFO] Noncompliant plan results written to $REPORT_DIR/kyverno-tfplan-noncompliant-report.yaml"