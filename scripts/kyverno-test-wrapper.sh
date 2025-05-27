#!/bin/bash

# Wrapper script for kyverno test command
# This wrapper helps handle edge cases and provide better error reporting

set -euo pipefail

# Check if kyverno is installed
if ! command -v kyverno &> /dev/null; then
    echo "Error: kyverno CLI not found. Please install it first."
    exit 1
fi

# Run kyverno test with proper error handling
echo "Running Kyverno tests..."

# If no arguments provided, show usage
if [ $# -eq 0 ]; then
    echo "Usage: $0 <policy-file> --resource <resource-dir>"
    echo "Example: $0 policies/kubernetes/pod-security/custom-5.1.1.yaml --resource tests/kubernetes/custom-5.1.1/"
    exit 1
fi

# Run the test and capture output
output=$(kyverno test "$@" 2>&1) || exit_code=$?

# Display the output
echo "$output"

# Check for common issues
if echo "$output" | grep -q "no test yamls available"; then
    echo "Warning: No test YAML files found in the specified directory"
    exit 1
fi

if echo "$output" | grep -q "failed"; then
    echo "Warning: Some tests failed"
    exit 1
fi

# Exit with the same code as kyverno test
exit ${exit_code:-0}