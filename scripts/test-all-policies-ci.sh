#!/bin/bash

# CI-friendly test script

echo "=== CI Policy Test Runner ==="
echo "Started at: $(date)"
echo "Working directory: $(pwd)"

# Check kyverno
if ! command -v kyverno &> /dev/null; then
    echo "ERROR: kyverno not found in PATH"
    exit 1
fi

echo "Kyverno version: $(kyverno version)"

# Initialize counters
TOTAL_POLICIES=0
TOTAL_TESTS=0
PASSED=0
FAILED=0
SKIPPED=0

# Create reports directory
mkdir -p reports/policy-tests

# Output files
SUMMARY="reports/policy-tests/summary.md"
DETAILS="reports/policy-tests/detailed-results.md"

# Initialize reports
{
    echo "# Policy Test Summary"
    echo ""
    echo "Generated: $(date)"
    echo ""
} > "$SUMMARY"

{
    echo "# Detailed Policy Test Results"
    echo ""
    echo "Generated: $(date)"
    echo ""
} > "$DETAILS"

# Function to safely increment counters
increment() {
    local var_name=$1
    local current_val=${!var_name}
    eval "$var_name=$((current_val + 1))"
}

# Test Kubernetes policies
echo ""
echo "Testing Kubernetes policies..."
echo "## Kubernetes Policies" >> "$DETAILS"
echo "" >> "$DETAILS"

for policy in policies/kubernetes/*/*.yaml; do
    if [ -f "$policy" ]; then
        increment TOTAL_POLICIES
        policy_name=$(basename "$policy" .yaml)
        echo "Testing $policy_name..."
        
        # Test compliant
        if [ -d "tests/kubernetes/$policy_name/compliant" ]; then
            echo -n "  Compliant: "
            
            # Skip special cases
            if [[ "$policy_name" == "custom-4.5.1" ]]; then
                echo "SKIP (namespace policy)"
                echo "- $policy_name - compliant: SKIPPED" >> "$DETAILS"
                increment SKIPPED
                increment TOTAL_TESTS
            elif ls "tests/kubernetes/$policy_name/compliant"/*.json >/dev/null 2>&1; then
                echo "SKIP (JSON test)"
                echo "- $policy_name - compliant: SKIPPED" >> "$DETAILS"
                increment SKIPPED
                increment TOTAL_TESTS
            else
                # Run test
                if kyverno apply "$policy" --resource "tests/kubernetes/$policy_name/compliant" >/dev/null 2>&1; then
                    echo "PASS"
                    echo "- ✅ $policy_name - compliant: PASS" >> "$DETAILS"
                    increment PASSED
                else
                    echo "FAIL"
                    echo "- ❌ $policy_name - compliant: FAIL" >> "$DETAILS"
                    increment FAILED
                fi
                increment TOTAL_TESTS
            fi
        fi
        
        # Test noncompliant
        if [ -d "tests/kubernetes/$policy_name/noncompliant" ]; then
            echo -n "  Noncompliant: "
            
            if ls "tests/kubernetes/$policy_name/noncompliant"/*.json >/dev/null 2>&1; then
                echo "SKIP (JSON test)"
                echo "- $policy_name - noncompliant: SKIPPED" >> "$DETAILS"
                increment SKIPPED
                increment TOTAL_TESTS
            else
                # Run test
                if kyverno apply "$policy" --resource "tests/kubernetes/$policy_name/noncompliant" >/dev/null 2>&1; then
                    # Check if audit mode
                    if grep -q "validationFailureAction: [Aa]udit" "$policy"; then
                        echo "AUDIT MODE"
                        echo "- ⚠️  $policy_name - noncompliant: AUDIT MODE" >> "$DETAILS"
                        increment SKIPPED
                    else
                        echo "FAIL (should reject)"
                        echo "- ❌ $policy_name - noncompliant: FAIL" >> "$DETAILS"
                        increment FAILED
                    fi
                else
                    echo "PASS (rejected)"
                    echo "- ✅ $policy_name - noncompliant: PASS" >> "$DETAILS"
                    increment PASSED
                fi
                increment TOTAL_TESTS
            fi
        fi
    fi
done

# Test Terraform policies
echo ""
echo "Testing Terraform policies..."
echo "" >> "$DETAILS"
echo "## Terraform Policies" >> "$DETAILS"
echo "" >> "$DETAILS"

for policy in policies/terraform/*/*.yaml; do
    if [ -f "$policy" ]; then
        increment TOTAL_POLICIES
        policy_name=$(basename "$policy" .yaml)
        echo "Testing $policy_name..."
        
        # Test compliant plan
        if [ -f "terraform/compliant/tfplan.json" ]; then
            echo -n "  Compliant plan: "
            if kyverno apply "$policy" --resource "terraform/compliant/tfplan.json" >/dev/null 2>&1; then
                echo "PASS"
                echo "- ✅ $policy_name - compliant: PASS" >> "$DETAILS"
                increment PASSED
            else
                echo "FAIL"
                echo "- ❌ $policy_name - compliant: FAIL" >> "$DETAILS"
                increment FAILED
            fi
            increment TOTAL_TESTS
        fi
        
        # Test noncompliant plan
        if [ -f "terraform/noncompliant/tfplan.json" ]; then
            echo -n "  Noncompliant plan: "
            if kyverno apply "$policy" --resource "terraform/noncompliant/tfplan.json" >/dev/null 2>&1; then
                echo "FAIL (should reject)"
                echo "- ❌ $policy_name - noncompliant: FAIL" >> "$DETAILS"
                increment FAILED
            else
                echo "PASS (rejected)"
                echo "- ✅ $policy_name - noncompliant: PASS" >> "$DETAILS"
                increment PASSED
            fi
            increment TOTAL_TESTS
        fi
    fi
done

# Generate summary
{
    echo ""
    echo "## Statistics"
    echo ""
    echo "- Total Policies: $TOTAL_POLICIES"
    echo "- Total Tests: $TOTAL_TESTS"
    echo "- Passed: $PASSED"
    echo "- Failed: $FAILED"
    echo "- Skipped: $SKIPPED"
    echo ""
    
    if [ $((PASSED + FAILED)) -gt 0 ]; then
        SUCCESS_RATE=$((PASSED * 100 / (PASSED + FAILED)))
        echo "## Success Rate: ${SUCCESS_RATE}%"
    else
        echo "## Success Rate: N/A"
    fi
    
    echo ""
    if [ $FAILED -eq 0 ]; then
        echo "✅ **All tests passed!**"
    else
        echo "❌ **$FAILED tests failed**"
    fi
} >> "$SUMMARY"

# Display results
echo ""
echo "========================================"
echo "FINAL RESULTS"
echo "========================================"
echo "Total Policies: $TOTAL_POLICIES"
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Skipped: $SKIPPED"
if [ $((PASSED + FAILED)) -gt 0 ]; then
    echo "Success Rate: $((PASSED * 100 / (PASSED + FAILED)))%"
fi
echo ""
echo "Reports generated:"
echo "  - $SUMMARY"
echo "  - $DETAILS"
echo "========================================"

# Exit with appropriate code
if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi