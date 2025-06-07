#!/bin/bash

set -euo pipefail

REPORTS_DIR="reports/opentofu-compliance"
POLICIES_DIR="policies/terraform"

mkdir -p "$REPORTS_DIR"

echo "=== OpenTofu Policy Compliance Tests ==="
echo "Started at: $(date)"

# Check if OpenTofu plans exist
if [ ! -f "opentofu/compliant/tofuplan.json" ] || [ ! -f "opentofu/noncompliant/tofuplan.json" ]; then
    echo "Error: OpenTofu plans not found. Please generate them first."
    echo "Run: cd opentofu/compliant && tofu plan -out=tofuplan.binary && tofu show -json tofuplan.binary > tofuplan.json"
    exit 1
fi

# Test compliant configuration
echo ""
echo "Testing compliant OpenTofu configuration..."
cat > "$REPORTS_DIR/compliant-plan-scan.md" << EOF
# OpenTofu Compliant Configuration Validation

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
        
        output=$(KYVERNO_EXPERIMENTAL=true kyverno json scan --policy "$policy" --payload "opentofu/compliant/tofuplan.json" 2>&1)
        if echo "$output" | grep -q "PASSED"; then
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
echo "Testing non-compliant OpenTofu configuration..."
cat > "$REPORTS_DIR/noncompliant-plan-scan.md" << EOF
# OpenTofu Non-Compliant Configuration Validation

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
        
        output=$(KYVERNO_EXPERIMENTAL=true kyverno json scan --policy "$policy" --payload "opentofu/noncompliant/tofuplan.json" 2>&1)
        
        if echo "$output" | grep -q "FAILED"; then
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
echo "=== OpenTofu compliance tests completed ==="
echo "Reports generated:"
echo "  - $REPORTS_DIR/compliant-plan-scan.md"
echo "  - $REPORTS_DIR/noncompliant-plan-scan.md"

# Exit with error if compliant config has failures
if [ $FAILED -gt 0 ]; then
    exit 1
fi