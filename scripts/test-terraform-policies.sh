#!/bin/bash

set -euo pipefail

REPORTS_DIR="reports/terraform-compliance"
POLICIES_DIR="policies/terraform"

mkdir -p "$REPORTS_DIR"

echo "=== Terraform Policy Compliance Tests ==="
echo "Started at: $(date)"

# Check if Terraform plans exist
if [ ! -f "terraform/compliant/tfplan.json" ] || [ ! -f "terraform/noncompliant/tfplan.json" ]; then
    echo "Error: Terraform plans not found. Please generate them first."
    echo "Run: cd terraform/compliant && terraform plan -out=tfplan.binary && terraform show -json tfplan.binary > tfplan.json"
    exit 1
fi

# Test compliant configuration
echo ""
echo "Testing compliant Terraform configuration..."
cat > "$REPORTS_DIR/compliant-plan-scan.md" << EOF
# Terraform Compliant Configuration Validation

**Generated**: $(date)

## Executive Summary

| Policy | Result |
|--------|--------|
EOF

PASSED=0
FAILED=0

for policy in "$POLICIES_DIR"/*/*.yaml; do
    if [ -f "$policy" ]; then
        policy_name=$(basename "$policy" .yaml)
        echo -n "  Testing $policy_name... "
        
        if kyverno apply "$policy" --resource "terraform/compliant/tfplan.json" >/dev/null 2>&1; then
            echo "✅ PASS"
            echo "| $policy_name | ✅ PASS |" >> "$REPORTS_DIR/compliant-plan-scan.md"
            ((PASSED++))
        else
            echo "❌ FAIL"
            echo "| $policy_name | ❌ FAIL |" >> "$REPORTS_DIR/compliant-plan-scan.md"
            ((FAILED++))
        fi
    fi
done

cat >> "$REPORTS_DIR/compliant-plan-scan.md" << EOF

## Summary

- **Total Policies**: $((PASSED + FAILED))
- **Passed**: $PASSED
- **Failed**: $FAILED
- **Success Rate**: $(( PASSED * 100 / (PASSED + FAILED) ))%
EOF

# Test non-compliant configuration
echo ""
echo "Testing non-compliant Terraform configuration..."
cat > "$REPORTS_DIR/noncompliant-plan-scan.md" << EOF
# Terraform Non-Compliant Configuration Validation

**Generated**: $(date)

## Executive Summary

| Policy | Result | Violation |
|--------|--------|-----------|
EOF

VIOLATIONS=0
NOT_DETECTED=0

for policy in "$POLICIES_DIR"/*/*.yaml; do
    if [ -f "$policy" ]; then
        policy_name=$(basename "$policy" .yaml)
        echo -n "  Testing $policy_name... "
        
        output=$(kyverno apply "$policy" --resource "terraform/noncompliant/tfplan.json" 2>&1 || true)
        
        if echo "$output" | grep -q "failed\|blocked\|violation\|error"; then
            echo "✅ Violation detected"
            echo "| $policy_name | ✅ Detected | Yes |" >> "$REPORTS_DIR/noncompliant-plan-scan.md"
            ((VIOLATIONS++))
        else
            echo "❌ No violation detected"
            echo "| $policy_name | ❌ Not Detected | No |" >> "$REPORTS_DIR/noncompliant-plan-scan.md"
            ((NOT_DETECTED++))
        fi
    fi
done

cat >> "$REPORTS_DIR/noncompliant-plan-scan.md" << EOF

## Summary

- **Total Policies**: $((VIOLATIONS + NOT_DETECTED))
- **Violations Detected**: $VIOLATIONS
- **Not Detected**: $NOT_DETECTED
- **Detection Rate**: $(( VIOLATIONS * 100 / (VIOLATIONS + NOT_DETECTED) ))%
EOF

echo ""
echo "=== Terraform compliance tests completed ==="
echo "Reports generated:"
echo "  - $REPORTS_DIR/compliant-plan-scan.md"
echo "  - $REPORTS_DIR/noncompliant-plan-scan.md"

# Exit with error if compliant config has failures
if [ $FAILED -gt 0 ]; then
    exit 1
fi