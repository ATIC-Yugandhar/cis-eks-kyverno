#!/bin/bash
set -e

RESULTS_FILE="reports/results-kyverno-tests.txt"
SUMMARY_FILE="reports/results-kyverno-summary.txt"

mkdir -p reports
rm -f "$RESULTS_FILE" "$SUMMARY_FILE"

PASSED=0
FAILED=0
ERRORS=0

TEMP_PASS="/tmp/kyverno_pass_count"
TEMP_FAIL="/tmp/kyverno_fail_count"
TEMP_ERROR="/tmp/kyverno_error_count"
echo "0" > "$TEMP_PASS"
echo "0" > "$TEMP_FAIL"
echo "0" > "$TEMP_ERROR"

while IFS= read -r testfile; do
  echo -e "\nRunning test: $testfile" | tee -a "$RESULTS_FILE"
  TEST_OUT=$(kyverno test "$(dirname "$testfile")" 2>&1)
  echo "$TEST_OUT" >> "$RESULTS_FILE"
  
  if echo "$TEST_OUT" | grep -q '\bPass\b'; then
    echo "$(($(cat "$TEMP_PASS") + 1))" > "$TEMP_PASS"
    echo "PASS: $testfile" >> "$SUMMARY_FILE"
  fi
  if echo "$TEST_OUT" | grep -q '\bFail\b'; then
    echo "$(($(cat "$TEMP_FAIL") + 1))" > "$TEMP_FAIL"
    echo "FAIL: $testfile" >> "$SUMMARY_FILE"
  fi
  if echo "$TEST_OUT" | grep -q '^Error:'; then
    echo "$(($(cat "$TEMP_ERROR") + 1))" > "$TEMP_ERROR"
    echo "ERROR: $testfile" >> "$SUMMARY_FILE"
  fi
done < <(find tests -type f -name 'kyverno-test.yaml' | sort)

PASSED=$(cat "$TEMP_PASS")
FAILED=$(cat "$TEMP_FAIL")
ERRORS=$(cat "$TEMP_ERROR")

rm -f "$TEMP_PASS" "$TEMP_FAIL" "$TEMP_ERROR"

TOTAL=$((PASSED+FAILED+ERRORS))
echo -e "\nSummary:"
echo "Total test cases: $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Errors: $ERRORS"
echo -e "\nSee $RESULTS_FILE and $SUMMARY_FILE for full details."