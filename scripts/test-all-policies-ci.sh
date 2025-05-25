#!/bin/bash

# Simple CI-friendly version of the test script
# Exit on error, but handle it gracefully
set -euo pipefail

# Basic setup
REPORT_DIR="reports/policy-tests"
RESULTS_FILE="$REPORT_DIR/detailed-results.md"
SUMMARY_FILE="$REPORT_DIR/summary.md"

# Create report directory
mkdir -p "$REPORT_DIR"

# Initialize counters
TOTAL_TESTS=0
PASSED=0
FAILED=0
ERRORS=0

echo "Starting Kyverno Policy Tests..."
echo "================================"

# Check environment
echo "Kyverno version: $(kyverno version 2>/dev/null || echo 'Not found')"
echo "Current directory: $(pwd)"
echo "Looking for tests in: tests/kubernetes"

# Find test files
if [ ! -d "tests/kubernetes" ]; then
    echo "ERROR: tests/kubernetes directory not found!"
    exit 1
fi

# Initialize report files
cat > "$RESULTS_FILE" << 'EOF'
# Kyverno Policy Test Results

## Test Execution Details

EOF

cat > "$SUMMARY_FILE" << 'EOF'
# Policy Test Summary

## Test Results

EOF

# Find and run tests
echo ""
echo "Discovering test files..."
while IFS= read -r testfile; do
    if [ -n "$testfile" ]; then
        ((TOTAL_TESTS++))
        echo "Running test $TOTAL_TESTS: $testfile"
        
        # Run the test
        if kyverno test "$(dirname "$testfile")" > /tmp/test_output.txt 2>&1; then
            echo "  ✓ PASSED"
            ((PASSED++))
            echo "- ✅ $testfile - **PASS**" >> "$SUMMARY_FILE"
        else
            echo "  ✗ FAILED"
            ((FAILED++))
            echo "- ❌ $testfile - **FAIL**" >> "$SUMMARY_FILE"
        fi
        
        # Add to detailed results
        echo "### Test: $testfile" >> "$RESULTS_FILE"
        echo '```' >> "$RESULTS_FILE"
        cat /tmp/test_output.txt >> "$RESULTS_FILE"
        echo '```' >> "$RESULTS_FILE"
        echo "" >> "$RESULTS_FILE"
    fi
done < <(find tests/kubernetes -type f -name 'kyverno-test.yaml' | sort)

# Final summary
echo ""
echo "Test Summary:"
echo "============="
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED"
echo "Failed: $FAILED"

# Add summary to report
cat >> "$SUMMARY_FILE" << EOF

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | $TOTAL_TESTS |
| Passed | $PASSED |
| Failed | $FAILED |
| Success Rate | $(( TOTAL_TESTS > 0 ? PASSED * 100 / TOTAL_TESTS : 0 ))% |

Generated at: $(date)
EOF

# Exit with appropriate code
if [ $FAILED -gt 0 ]; then
    echo "Some tests failed!"
    exit 1
else
    echo "All tests passed!"
    exit 0
fi