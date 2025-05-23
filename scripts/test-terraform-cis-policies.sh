#!/bin/bash
set -euo pipefail

# Enable Kyverno experimental features for Terraform plan scanning
export KYVERNO_EXPERIMENTAL=true
COMPLIANT_DIR="terraform/compliant"
NONCOMPLIANT_DIR="terraform/noncompliant"
POLICY_DIR="kyverno-policies/terraform"
REPORT_DIR="reports/terraform-compliance"

mkdir -p "$REPORT_DIR"

if [ ! -d "$COMPLIANT_DIR" ]; then
    echo "[ERROR] Compliant directory not found: $COMPLIANT_DIR"
    exit 1
fi

if [ ! -d "$NONCOMPLIANT_DIR" ]; then
    echo "[ERROR] Noncompliant directory not found: $NONCOMPLIANT_DIR"
    exit 1
fi

if [ ! -d "$POLICY_DIR" ]; then
    echo "[ERROR] Policy directory not found: $POLICY_DIR"
    exit 1
fi

POLICY_FILES_COUNT=$(find "$POLICY_DIR" -name "*.yaml" -type f | wc -l)
if [ "$POLICY_FILES_COUNT" -eq 0 ]; then
    echo "[ERROR] No policy files found in $POLICY_DIR"
    exit 1
fi

echo "[INFO] Found $POLICY_FILES_COUNT policy files in $POLICY_DIR"

echo "[INFO] Initializing compliant Terraform configuration..."
terraform -chdir="$COMPLIANT_DIR" init -input=false -no-color

echo "[INFO] Planning compliant stack..."
terraform -chdir="$COMPLIANT_DIR" plan -out=tfplan.binary -input=false -no-color

echo "[INFO] Converting plan to JSON..."
rm -rf "$COMPLIANT_DIR/tfplan.json"
terraform -chdir="$COMPLIANT_DIR" show -json tfplan.binary > "$COMPLIANT_DIR/tfplan.json"

if [ ! -f "$COMPLIANT_DIR/tfplan.json" ]; then
    echo "[ERROR] Failed to generate tfplan.json for compliant configuration"
    exit 1
fi

echo "# Kyverno Terraform Plan Compliance Report - Compliant Configuration" > "$REPORT_DIR/compliant-plan-scan.yaml"
echo "# Generated on: $(date)" >> "$REPORT_DIR/compliant-plan-scan.yaml"
echo "" >> "$REPORT_DIR/compliant-plan-scan.yaml"

POLICY_COUNT=0
SCAN_ERRORS=0

for policy in "$POLICY_DIR"/*.yaml; do
  if [ -f "$policy" ]; then
    ((POLICY_COUNT++))
    echo "[INFO] Scanning $(basename "$policy") against compliant tfplan.json" | tee -a "$REPORT_DIR/compliant-plan-scan.yaml"
    
    set +e
    kyverno json scan --policy "$policy" --payload "$COMPLIANT_DIR/tfplan.json" >> "$REPORT_DIR/compliant-plan-scan.yaml" 2>&1
    SCAN_EXIT_CODE=$?
    set -e
    
    if [ $SCAN_EXIT_CODE -ne 0 ]; then
      ((SCAN_ERRORS++))
      echo "[WARN] Policy scan failed with exit code $SCAN_EXIT_CODE: $(basename "$policy")" | tee -a "$REPORT_DIR/compliant-plan-scan.yaml"
    fi
    
    echo "" >> "$REPORT_DIR/compliant-plan-scan.yaml"
  fi
done

echo "[INFO] Compliant plan scan completed. Policies scanned: $POLICY_COUNT, Errors: $SCAN_ERRORS"
echo "[INFO] Results written to $REPORT_DIR/compliant-plan-scan.yaml"

echo "[INFO] Initializing noncompliant Terraform configuration..."
terraform -chdir="$NONCOMPLIANT_DIR" init -input=false -no-color

echo "[INFO] Planning noncompliant stack..."
terraform -chdir="$NONCOMPLIANT_DIR" plan -out=tfplan.binary -input=false -no-color

echo "[INFO] Converting plan to JSON..."
rm -rf "$NONCOMPLIANT_DIR/tfplan.json"
terraform -chdir="$NONCOMPLIANT_DIR" show -json tfplan.binary > "$NONCOMPLIANT_DIR/tfplan.json"

if [ ! -f "$NONCOMPLIANT_DIR/tfplan.json" ]; then
    echo "[ERROR] Failed to generate tfplan.json for noncompliant configuration"
    exit 1
fi

echo "# Kyverno Terraform Plan Compliance Report - Noncompliant Configuration" > "$REPORT_DIR/noncompliant-plan-scan.yaml"
echo "# Generated on: $(date)" >> "$REPORT_DIR/noncompliant-plan-scan.yaml"
echo "" >> "$REPORT_DIR/noncompliant-plan-scan.yaml"

POLICY_COUNT_NC=0
SCAN_ERRORS_NC=0

for policy in "$POLICY_DIR"/*.yaml; do
  if [ -f "$policy" ]; then
    ((POLICY_COUNT_NC++))
    echo "[INFO] Scanning $(basename "$policy") against noncompliant tfplan.json" | tee -a "$REPORT_DIR/noncompliant-plan-scan.yaml"
    
    set +e
    kyverno json scan --policy "$policy" --payload "$NONCOMPLIANT_DIR/tfplan.json" >> "$REPORT_DIR/noncompliant-plan-scan.yaml" 2>&1
    SCAN_EXIT_CODE=$?
    set -e
    
    if [ $SCAN_EXIT_CODE -ne 0 ]; then
      ((SCAN_ERRORS_NC++))
      echo "[WARN] Policy scan failed with exit code $SCAN_EXIT_CODE: $(basename "$policy")" | tee -a "$REPORT_DIR/noncompliant-plan-scan.yaml"
    fi
    
    echo "" >> "$REPORT_DIR/noncompliant-plan-scan.yaml"
  fi
done

echo "[INFO] Noncompliant plan scan completed. Policies scanned: $POLICY_COUNT_NC, Errors: $SCAN_ERRORS_NC"
echo "[INFO] Results written to $REPORT_DIR/noncompliant-plan-scan.yaml"

echo ""
echo "=========================================="
echo "TERRAFORM PLAN SCANNING SUMMARY"
echo "=========================================="
echo "Compliant configuration:"
echo "  - Policies scanned: $POLICY_COUNT"
echo "  - Scan errors: $SCAN_ERRORS"
echo "Noncompliant configuration:"
echo "  - Policies scanned: $POLICY_COUNT_NC"
echo "  - Scan errors: $SCAN_ERRORS_NC"
echo "=========================================="

TOTAL_ERRORS=$((SCAN_ERRORS + SCAN_ERRORS_NC))
if [ $TOTAL_ERRORS -gt 0 ]; then
    echo ""
    echo "[ERROR] Total scan errors: $TOTAL_ERRORS"
    exit 1
fi

echo ""
echo "[SUCCESS] All Terraform plan scans completed successfully"
exit 0