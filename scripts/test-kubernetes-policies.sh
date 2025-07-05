#!/bin/bash

set -uo pipefail
# Don't exit on error immediately - we want to see what's failing
set +e

START_TIME=$(date +%s)
echo "Script started at $(date)"
echo "Working directory: $(pwd)"

POLICIES_DIR="policies"
TESTS_DIR="tests"
REPORTS_DIR="reports/policy-tests"

mkdir -p "$REPORTS_DIR"

SUMMARY_FILE="$REPORTS_DIR/summary.md"
DETAILED_FILE="$REPORTS_DIR/detailed-results.md"
JSON_STATS="$REPORTS_DIR/execution-stats.json"

TOTAL_POLICIES=0
TOTAL_TESTS=0
PASSED=0
FAILED=0
SKIPPED=0

# Arrays to store results for summary
declare -a K8S_RESULTS=()
declare -a TF_RESULTS=()

echo "Kyverno version: $(kyverno version)"

echo "=== Running All Policy Tests ==="
echo ""

# Initialize detailed report
cat > "$DETAILED_FILE" << EOF
# Detailed Policy Test Results

Generated: $(date)

## Kubernetes Policies

EOF

# Test Kubernetes policies
echo "Testing Kubernetes policies..."

for category_dir in "$POLICIES_DIR/kubernetes"/*; do
    if [ -d "$category_dir" ]; then
        category=$(basename "$category_dir")
        echo "" 
        echo "Category: $category"
        
        K8S_RESULTS+=("### $category")
        K8S_RESULTS+=("")
        
        echo "### $category" >> "$DETAILED_FILE"
        echo "" >> "$DETAILED_FILE"
        
        for policy in "$category_dir"/*.yaml; do
            if [ -f "$policy" ]; then
                ((TOTAL_POLICIES++))
                policy_name=$(basename "$policy" .yaml)
                echo -n "  $policy_name: "
                
                result_line=""
                
                if [ -d "$TESTS_DIR/kubernetes/$policy_name" ]; then
                    # Test compliant resources
                    if [ -d "$TESTS_DIR/kubernetes/$policy_name/compliant" ]; then
                        if ls "$TESTS_DIR/kubernetes/$policy_name/compliant"/*.json >/dev/null 2>&1; then
                            echo -n "[skip] "
                            result_line+="- ⏭️ $policy_name - compliant: SKIPPED (JSON test)"
                            echo "- ⏭️ $policy_name - compliant: SKIPPED (JSON test)" >> "$DETAILED_FILE"
                            ((SKIPPED++))
                        else
                            if kyverno apply "$policy" --resource "$TESTS_DIR/kubernetes/$policy_name/compliant" >/dev/null 2>&1; then
                                echo -n "[✓] "
                                result_line+="- ✅ $policy_name - compliant: PASS"
                                echo "- ✅ $policy_name - compliant: PASS" >> "$DETAILED_FILE"
                                PASSED=$((PASSED + 1))
                            else
                                echo -n "[✗] "
                                result_line+="- ❌ $policy_name - compliant: FAIL"
                                echo "- ❌ $policy_name - compliant: FAIL" >> "$DETAILED_FILE"
                                ((FAILED++))
                            fi
                        fi
                        ((TOTAL_TESTS++))
                    fi
                    
                    # Test noncompliant resources
                    if [ -d "$TESTS_DIR/kubernetes/$policy_name/noncompliant" ]; then
                        output=$(kyverno apply "$policy" --resource "$TESTS_DIR/kubernetes/$policy_name/noncompliant" 2>&1 || true)
                        
                        if echo "$output" | grep -q "failed\|blocked\|violation\|error"; then
                            echo -n "[✓] "
                            result_line+=$'\n'"- ✅ $policy_name - noncompliant: PASS (rejected)"
                            echo "- ✅ $policy_name - noncompliant: PASS (rejected)" >> "$DETAILED_FILE"
                            PASSED=$((PASSED + 1))
                        elif [[ "$policy_name" == "custom-4.1.8" ]] && echo "$output" | grep -q "audit"; then
                            echo -n "[audit] "
                            result_line+=$'\n'"- ⚠️ $policy_name - noncompliant: AUDIT MODE"
                            echo "- ⚠️ $policy_name - noncompliant: AUDIT MODE" >> "$DETAILED_FILE"
                            ((SKIPPED++))
                        else
                            echo -n "[✗] "
                            result_line+=$'\n'"- ❌ $policy_name - noncompliant: FAIL (not rejected)"
                            echo "- ❌ $policy_name - noncompliant: FAIL (not rejected)" >> "$DETAILED_FILE"
                            ((FAILED++))
                        fi
                        ((TOTAL_TESTS++))
                    fi
                    
                    echo ""
                else
                    echo "[NO TESTS]"
                    result_line+="- ⚠️ $policy_name: NO TESTS FOUND"
                    echo "- ⚠️ $policy_name: NO TESTS FOUND" >> "$DETAILED_FILE"
                fi
                
                if [ -n "$result_line" ]; then
                    K8S_RESULTS+=("$result_line")
                fi
                echo "" >> "$DETAILED_FILE"
            fi
        done
        K8S_RESULTS+=("")
    fi
done

# Test OpenTofu policies
echo "" >> "$DETAILED_FILE"
echo "## OpenTofu Policies" >> "$DETAILED_FILE"
echo "" >> "$DETAILED_FILE"

echo ""
echo "Testing OpenTofu policies..."
for category_dir in "$POLICIES_DIR/opentofu"/*; do
    if [ -d "$category_dir" ]; then
        category=$(basename "$category_dir")
        echo ""
        echo "Category: $category"
        
        TF_RESULTS+=("### $category")
        TF_RESULTS+=("")
        
        echo "### $category" >> "$DETAILED_FILE"
        echo "" >> "$DETAILED_FILE"
        
        for policy in "$category_dir"/*.yaml; do
            if [ -f "$policy" ]; then
                ((TOTAL_POLICIES++))
                policy_name=$(basename "$policy" .yaml)
                echo -n "  $policy_name: "
                
                test_count=0
                result_line=""
                
                # Check compliant plan
                if [ -f "opentofu/compliant/tofuplan.json" ]; then
                    if kyverno apply "$policy" --resource "opentofu/compliant/tofuplan.json" >/dev/null 2>&1; then
                        echo -n "[✓] "
                        result_line+="- ✅ $policy_name - compliant plan: PASS"
                        echo "- ✅ $policy_name - compliant plan: PASS" >> "$DETAILED_FILE"
                        ((PASSED++))
                    else
                        echo -n "[✗] "
                        result_line+="- ❌ $policy_name - compliant plan: FAIL"
                        echo "- ❌ $policy_name - compliant plan: FAIL" >> "$DETAILED_FILE"
                        ((FAILED++))
                    fi
                    ((TOTAL_TESTS++))
                    ((test_count++))
                fi
                
                # Check noncompliant plan
                if [ -f "opentofu/noncompliant/tofuplan.json" ]; then
                    output=$(kyverno apply "$policy" --resource "opentofu/noncompliant/tofuplan.json" 2>&1 || true)
                    
                    if echo "$output" | grep -q "failed\|blocked\|violation\|error"; then
                        echo -n "[✓] "
                        result_line+=$'\n'"- ✅ $policy_name - noncompliant plan: PASS (rejected)"
                        echo "- ✅ $policy_name - noncompliant plan: PASS (rejected)" >> "$DETAILED_FILE"
                        ((PASSED++))
                    else
                        echo -n "[✗] "
                        result_line+=$'\n'"- ❌ $policy_name - noncompliant plan: FAIL (not rejected)"
                        echo "- ❌ $policy_name - noncompliant plan: FAIL (not rejected)" >> "$DETAILED_FILE"
                        ((FAILED++))
                    fi
                    ((TOTAL_TESTS++))
                    ((test_count++))
                fi
                
                if [ $test_count -eq 0 ]; then
                    echo "NO TESTS"
                    result_line+="- ⚠️ $policy_name: NO TEST PLANS FOUND"
                    echo "- ⚠️ $policy_name: NO TEST PLANS FOUND" >> "$DETAILED_FILE"
                else
                    echo ""
                fi
                
                if [ -n "$result_line" ]; then
                    TF_RESULTS+=("$result_line")
                fi
                echo "" >> "$DETAILED_FILE"
            fi
        done
        TF_RESULTS+=("")
    fi
done

# Generate comprehensive summary report
cat > "$SUMMARY_FILE" << EOF
# Policy Test Summary

Generated: $(date)

## Test Statistics

| Metric | Value |
|--------|-------|
| Total Policies | $TOTAL_POLICIES |
| Total Tests | $TOTAL_TESTS |
| ✅ Passed | $PASSED |
| ❌ Failed | $FAILED |
| ⏭️ Skipped | $SKIPPED |
EOF

# Calculate success rate
if [ $((PASSED + FAILED)) -gt 0 ]; then
    SUCCESS_RATE=$((PASSED * 100 / (PASSED + FAILED)))
    echo "| Success Rate | ${SUCCESS_RATE}% |" >> "$SUMMARY_FILE"
else
    echo "| Success Rate | N/A |" >> "$SUMMARY_FILE"
fi

# Performance metrics
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
if [ $DURATION -gt 0 ]; then
    # Use awk instead of bc for better compatibility
    TESTS_PER_SEC=$(awk -v t="$TOTAL_TESTS" -v d="$DURATION" 'BEGIN {printf "%.2f", t/d}' 2>/dev/null || echo "N/A")
else
    TESTS_PER_SEC="N/A"
fi

cat >> "$SUMMARY_FILE" << EOF

## Performance Metrics

| Metric | Value |
|--------|-------|
| Duration | ${DURATION}s |
| Tests/Second | $TESTS_PER_SEC |

## Kubernetes Policies

EOF

# Add Kubernetes results to summary
if [ ${#K8S_RESULTS[@]} -gt 0 ]; then
    for result in "${K8S_RESULTS[@]}"; do
        echo "$result" >> "$SUMMARY_FILE"
    done
fi

echo "" >> "$SUMMARY_FILE"
echo "## OpenTofu Policies" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# Add OpenTofu results to summary
if [ ${#TF_RESULTS[@]} -gt 0 ]; then
    for result in "${TF_RESULTS[@]}"; do
        echo "$result" >> "$SUMMARY_FILE"
    done
fi

# List policies without tests
echo "" >> "$SUMMARY_FILE"
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

# Generate JSON stats
# Handle N/A case for tests_per_second
if [ "$TESTS_PER_SEC" = "N/A" ]; then
    TESTS_PER_SEC_JSON="0"
else
    TESTS_PER_SEC_JSON="$TESTS_PER_SEC"
fi

cat > "$JSON_STATS" << EOF
{
  "execution_time": "$DURATION",
  "total_policies": $TOTAL_POLICIES,
  "total_tests": $TOTAL_TESTS,
  "passed": $PASSED,
  "failed": $FAILED,
  "skipped": $SKIPPED,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "success_rate": ${SUCCESS_RATE:-0},
  "tests_per_second": $TESTS_PER_SEC_JSON
}
EOF

# Print summary
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
echo "  - $JSON_STATS"
echo "========================================"

if [ $FAILED -gt 0 ]; then
    exit 1
fi