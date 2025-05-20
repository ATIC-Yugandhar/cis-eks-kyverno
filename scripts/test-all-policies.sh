#!/bin/bash
set -e

RESULTS_FILE="reports/results-kyverno-tests.txt"
SUMMARY_FILE="reports/results-kyverno-summary.txt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

# Ensure reports directory exists and delete previous results files
mkdir -p "${BASE_DIR}/reports"
rm -f "${BASE_DIR}/${RESULTS_FILE}" "${BASE_DIR}/${SUMMARY_FILE}"

export KYVERNO_EXPERIMENTAL=true

# Verify kyverno CLI is installed
if ! command -v kyverno &> /dev/null; then
  echo "ERROR: Kyverno CLI not found. Please make sure it's installed."
  exit 1
fi

echo "Using Kyverno CLI: $(which kyverno)"
echo "Kyverno version: $(kyverno version)"

PASSED=0
FAILED=0
ERRORS=0

# Find all kyverno-test.yaml files and run them individually
cd "${BASE_DIR}"
find tests -type f -name 'kyverno-test.yaml' | sort | while read testfile; do
  echo -e "\nRunning test: $testfile" | tee -a "$RESULTS_FILE"
  
  TEST_DIR="$(dirname "$testfile")"
  echo "Test directory: $TEST_DIR"
  
  # Use --resources-dir to explicitly point to the directory
  TEST_OUT=$(kyverno test --resources-dir "$TEST_DIR" 2>&1) || true
  
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