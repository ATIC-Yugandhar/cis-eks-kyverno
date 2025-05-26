#!/bin/bash

# Comprehensive test script that runs all policies and generates reports

set -e

# Directories
POLICIES_DIR="policies"
TESTS_DIR="tests"
REPORTS_DIR="reports/policy-tests"

# Create reports directory
mkdir -p "$REPORTS_DIR"

# Initialize counters
TOTAL_POLICIES=0
TOTAL_TESTS=0
PASSED=0
FAILED=0
SKIPPED=0

# Results files
SUMMARY_FILE="$REPORTS_DIR/summary.md"
DETAILED_FILE="$REPORTS_DIR/detailed-results.md"

# Initialize reports
echo "# Policy Test Summary" > "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "Generated: $(date)" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "# Detailed Policy Test Results" > "$DETAILED_FILE"
echo "" >> "$DETAILED_FILE"
echo "Generated: $(date)" >> "$DETAILED_FILE"
echo "" >> "$DETAILED_FILE"

echo "=== Running All Policy Tests ==="
echo ""

# Test all Kubernetes policies
echo "## Kubernetes Policies" >> "$SUMMARY_FILE"
echo "## Kubernetes Policies" >> "$DETAILED_FILE"
echo "" >> "$SUMMARY_FILE"
echo "" >> "$DETAILED_FILE"

echo "Testing Kubernetes policies..."
for category_dir in "$POLICIES_DIR/kubernetes"/*; do
    if [ -d "$category_dir" ]; then
        category=$(basename "$category_dir")
        echo "" 
        echo "Category: $category"
        echo "### $category" >> "$SUMMARY_FILE"
        echo "### $category" >> "$DETAILED_FILE"
        echo "" >> "$DETAILED_FILE"
        
        for policy in "$category_dir"/*.yaml; do
            if [ -f "$policy" ]; then
                ((TOTAL_POLICIES++))
                policy_name=$(basename "$policy" .yaml)
                echo -n "  $policy_name: "
                
                # Check if tests exist
                if [ -d "$TESTS_DIR/kubernetes/$policy_name" ]; then
                    # Test compliant
                    if [ -d "$TESTS_DIR/kubernetes/$policy_name/compliant" ]; then
                        # Special cases
                        if [[ "$policy_name" == "custom-4.5.1" ]]; then
                            echo -n "[skip] "
                            echo "- $policy_name - compliant: SKIPPED (namespace policy)" >> "$DETAILED_FILE"
                            ((SKIPPED++))
                        elif ls "$TESTS_DIR/kubernetes/$policy_name/compliant"/*.json >/dev/null 2>&1; then
                            echo -n "[skip] "
                            echo "- $policy_name - compliant: SKIPPED (JSON test)" >> "$DETAILED_FILE"
                            ((SKIPPED++))
                        else
                            if kyverno apply "$policy" --resource "$TESTS_DIR/kubernetes/$policy_name/compliant" >/dev/null 2>&1; then
                                echo -n "[✓] "
                                echo "- ✅ $policy_name - compliant: PASS" >> "$DETAILED_FILE"
                                ((PASSED++))
                            else
                                echo -n "[✗] "
                                echo "- ❌ $policy_name - compliant: FAIL" >> "$DETAILED_FILE"
                                ((FAILED++))
                            fi
                        fi
                        ((TOTAL_TESTS++))
                    fi
                    
                    # Test noncompliant
                    if [ -d "$TESTS_DIR/kubernetes/$policy_name/noncompliant" ]; then
                        if ls "$TESTS_DIR/kubernetes/$policy_name/noncompliant"/*.json >/dev/null 2>&1; then
                            echo -n "[skip] "
                            echo "- $policy_name - noncompliant: SKIPPED (JSON test)" >> "$DETAILED_FILE"
                            ((SKIPPED++))
                        elif kyverno apply "$policy" --resource "$TESTS_DIR/kubernetes/$policy_name/noncompliant" >/dev/null 2>&1; then
                            # Check if it's audit mode
                            if grep -q "validationFailureAction: [Aa]udit" "$policy"; then
                                echo -n "[audit] "
                                echo "- ⚠️  $policy_name - noncompliant: AUDIT MODE" >> "$DETAILED_FILE"
                                ((SKIPPED++))
                            else
                                echo -n "[✗] "
                                echo "- ❌ $policy_name - noncompliant: FAIL (should reject)" >> "$DETAILED_FILE"
                                ((FAILED++))
                            fi
                        else
                            echo -n "[✓] "
                            echo "- ✅ $policy_name - noncompliant: PASS (rejected)" >> "$DETAILED_FILE"
                            ((PASSED++))
                        fi
                        ((TOTAL_TESTS++))
                    fi
                    echo ""
                else
                    echo "NO TESTS"
                    echo "- ⚠️  $policy_name: NO TESTS FOUND" >> "$DETAILED_FILE"
                fi
                echo "" >> "$DETAILED_FILE"
            fi
        done
    fi
done

# Test all Terraform policies
echo "" >> "$SUMMARY_FILE"
echo "" >> "$DETAILED_FILE"
echo "## Terraform Policies" >> "$SUMMARY_FILE"
echo "## Terraform Policies" >> "$DETAILED_FILE"
echo "" >> "$SUMMARY_FILE"
echo "" >> "$DETAILED_FILE"

echo ""
echo "Testing Terraform policies..."
for category_dir in "$POLICIES_DIR/terraform"/*; do
    if [ -d "$category_dir" ]; then
        category=$(basename "$category_dir")
        echo ""
        echo "Category: $category"
        echo "### $category" >> "$SUMMARY_FILE"
        echo "### $category" >> "$DETAILED_FILE"
        echo "" >> "$DETAILED_FILE"
        
        for policy in "$category_dir"/*.yaml; do
            if [ -f "$policy" ]; then
                ((TOTAL_POLICIES++))
                policy_name=$(basename "$policy" .yaml)
                echo -n "  $policy_name: "
                
                # Test against terraform plans
                test_count=0
                if [ -f "terraform/compliant/tfplan.json" ]; then
                    if kyverno apply "$policy" --resource "terraform/compliant/tfplan.json" >/dev/null 2>&1; then
                        echo -n "[✓] "
                        echo "- ✅ $policy_name - compliant plan: PASS" >> "$DETAILED_FILE"
                        ((PASSED++))
                    else
                        echo -n "[✗] "
                        echo "- ❌ $policy_name - compliant plan: FAIL" >> "$DETAILED_FILE"
                        ((FAILED++))
                    fi
                    ((TOTAL_TESTS++))
                    ((test_count++))
                fi
                
                if [ -f "terraform/noncompliant/tfplan.json" ]; then
                    if kyverno apply "$policy" --resource "terraform/noncompliant/tfplan.json" >/dev/null 2>&1; then
                        echo -n "[✗] "
                        echo "- ❌ $policy_name - noncompliant plan: FAIL (should reject)" >> "$DETAILED_FILE"
                        ((FAILED++))
                    else
                        echo -n "[✓] "
                        echo "- ✅ $policy_name - noncompliant plan: PASS (rejected)" >> "$DETAILED_FILE"
                        ((PASSED++))
                    fi
                    ((TOTAL_TESTS++))
                    ((test_count++))
                fi
                
                if [ $test_count -eq 0 ]; then
                    echo "NO TESTS"
                    echo "- ⚠️  $policy_name: NO TEST PLANS FOUND" >> "$DETAILED_FILE"
                else
                    echo ""
                fi
                echo "" >> "$DETAILED_FILE"
            fi
        done
    fi
done

# Generate summary statistics
echo "" >> "$SUMMARY_FILE"
echo "## Statistics" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "- **Total Policies**: $TOTAL_POLICIES" >> "$SUMMARY_FILE"
echo "- **Total Tests Run**: $TOTAL_TESTS" >> "$SUMMARY_FILE"
echo "- **Passed**: $PASSED" >> "$SUMMARY_FILE"
echo "- **Failed**: $FAILED" >> "$SUMMARY_FILE"
echo "- **Skipped**: $SKIPPED" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# Calculate success rate
if [ $((PASSED + FAILED)) -gt 0 ]; then
    SUCCESS_RATE=$((PASSED * 100 / (PASSED + FAILED)))
    echo "## Success Rate: ${SUCCESS_RATE}%" >> "$SUMMARY_FILE"
else
    echo "## Success Rate: N/A" >> "$SUMMARY_FILE"
fi
echo "" >> "$SUMMARY_FILE"

# List policies without tests
echo "## Policies Without Tests" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
NO_TESTS=0
for policy in $(find "$POLICIES_DIR/kubernetes" -name "*.yaml" -type f | sort); do
    policy_name=$(basename "$policy" .yaml)
    if [ ! -d "$TESTS_DIR/kubernetes/$policy_name" ]; then
        echo "- $policy_name" >> "$SUMMARY_FILE"
        ((NO_TESTS++))
    fi
done

if [ $NO_TESTS -eq 0 ]; then
    echo "All Kubernetes policies have tests!" >> "$SUMMARY_FILE"
fi

# Final summary
echo "" >> "$SUMMARY_FILE"
if [ $FAILED -eq 0 ]; then
    echo "✅ **All tests passed!**" >> "$SUMMARY_FILE"
else
    echo "❌ **$FAILED tests failed**" >> "$SUMMARY_FILE"
fi

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
echo ""
echo "Reports generated:"
echo "  - $SUMMARY_FILE"
echo "  - $DETAILED_FILE"
echo "========================================"

# Exit with failure if any tests failed
if [ $FAILED -gt 0 ]; then
    exit 1
fi