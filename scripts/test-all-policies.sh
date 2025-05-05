#!/bin/bash
set -e

RESULTS_FILE="results-kyverno-tests.txt"
SUMMARY_FILE="results-kyverno-summary.txt"

# Delete previous results files
rm -f "$RESULTS_FILE" "$SUMMARY_FILE"

PASSED=0
FAILED=0
ERRORS=0

# Find all kyverno-test.yaml files and run them individually
find tests -type f -name 'kyverno-test.yaml' | sort | while read testfile; do
  echo -e "\nRunning test: $testfile" | tee -a "$RESULTS_FILE"
  TEST_OUT=$(kyverno test "$(dirname "$testfile")" 2>&1)
  echo "$TEST_OUT" >> "$RESULTS_FILE"
  if echo "$TEST_OUT" | grep -q '\bPass\b'; then
    ((PASSED++))
    echo "PASS: $testfile" >> "$SUMMARY_FILE"
  fi
  if echo "$TEST_OUT" | grep -q '\bFail\b'; then
    ((FAILED++))
    echo "FAIL: $testfile" >> "$SUMMARY_FILE"
  fi
  if echo "$TEST_OUT" | grep -q '^Error:'; then
    ((ERRORS++))
    echo "ERROR: $testfile" >> "$SUMMARY_FILE"
  fi
done

# Print summary
TOTAL=$((PASSED+FAILED+ERRORS))
echo -e "\nSummary:"
echo "Total test cases: $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Errors: $ERRORS"
echo -e "\nSee $RESULTS_FILE and $SUMMARY_FILE for full details." 