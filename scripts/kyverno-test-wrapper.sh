#!/bin/bash

# Wrapper script for Kyverno tests that properly validates expected vs actual results
# Works around the known bug where tests expecting failures are marked as passed

set -euo pipefail

TEST_DIR="${1:-.}"
TEMP_OUTPUT=$(mktemp)
FAILED_TESTS=0
TOTAL_TESTS=0
MISMATCHED_TESTS=()

# Function to run tests and check results
check_test_results() {
    local test_dir="$1"
    local test_file
    
    # Find kyverno-test.yaml file
    test_file=$(find "$test_dir" -name "kyverno-test.yaml" -type f | head -1)
    
    if [[ -z "$test_file" ]]; then
        echo "Warning: No kyverno-test.yaml found in $test_dir"
        return 1
    fi
    
    # Run kyverno test and capture output
    echo "Running Kyverno tests in: $test_dir"
    if kyverno test "$test_dir" --detailed-results > "$TEMP_OUTPUT" 2>&1; then
        KYVERNO_EXIT=0
    else
        KYVERNO_EXIT=$?
    fi
    
    # Display the output
    cat "$TEMP_OUTPUT"
    
    # Check for common indicators of test failures
    # Look for validation errors with Pass results (indicates audit mode issue)
    # Strip ANSI color codes and clean up output
    local CLEANED_OUTPUT=$(mktemp)
    # Remove ANSI codes and convert UTF-8 box chars to ASCII
    sed 's/\x1b\[[0-9;]*m//g' "$TEMP_OUTPUT" | sed 's/│/|/g' > "$CLEANED_OUTPUT"
    
    if grep -E "validation error:.*Pass" "$CLEANED_OUTPUT" | grep -q .; then
        echo ""
        echo "⚠️  WARNING: Found validation errors that are passing due to audit mode"
        
        # Count how many validation errors are passing
        local error_count=$(grep -E "validation error:.*Pass" "$CLEANED_OUTPUT" | grep -c . || echo 0)
        FAILED_TESTS=$((FAILED_TESTS + error_count))
        
        # Extract details of failures
        while IFS= read -r line; do
            if [[ $line =~ "validation error:" ]]; then
                # Extract policy and resource info from the table row
                # Format: | ID | POLICY | RULE | RESOURCE | RESULT | REASON | MESSAGE |
                local policy=$(echo "$line" | cut -d'|' -f3 | xargs)
                local resource=$(echo "$line" | cut -d'|' -f5 | xargs)
                MISMATCHED_TESTS+=("Policy: $policy, Resource: $resource - Policy detected violation but is in audit mode")
            fi
        done < "$CLEANED_OUTPUT"
    fi
    
    # Count total tests
    if grep -q "Applying.*policy.*to.*resource" "$TEMP_OUTPUT"; then
        TOTAL_TESTS=$(grep -oE "Applying [0-9]+ polic" "$TEMP_OUTPUT" | grep -oE "[0-9]+" | head -1)
    fi
    
    # Also check if we're in a noncompliant directory but all tests passed
    if [[ "$test_dir" =~ noncompliant ]] && grep -q "Test Summary:.*tests passed and 0 tests failed" "$TEMP_OUTPUT"; then
        echo ""
        echo "⚠️  WARNING: Noncompliant tests are all passing - policies may not be enforcing"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        MISMATCHED_TESTS+=("All noncompliant tests passed - expected some failures")
    fi
    
    # Clean up temporary file
    rm -f "$CLEANED_OUTPUT"
}

# Main execution
check_test_results "$TEST_DIR"

# Clean up
rm -f "$TEMP_OUTPUT"

# Report actual results
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Validation Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAILED_TESTS" -eq 0 ]; then
    if [ "$TOTAL_TESTS" -eq 0 ]; then
        echo "⚠️  Warning: No tests were executed"
        exit 1
    else
        echo "✅ All tests produced expected results"
        echo "   (No validation errors found in passing tests)"
        exit 0
    fi
else
    echo "❌ Found $FAILED_TESTS validation issues"
    echo ""
    if [ ${#MISMATCHED_TESTS[@]} -gt 0 ]; then
        echo "Issues found:"
        for mismatch in "${MISMATCHED_TESTS[@]}"; do
            echo "  - $mismatch"
        done
    fi
    echo ""
    echo "Note: Most issues are due to policies being in 'audit' mode"
    echo "      In audit mode, policies log violations but don't block resources"
    echo "      This causes tests expecting failures to pass instead"
    exit 1
fi