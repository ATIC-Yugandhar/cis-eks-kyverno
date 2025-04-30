#!/bin/bash
#
# validate-cis.sh
#
# This script uses the Kyverno CLI to validate Kubernetes resources
# against the CIS (Center for Internet Security) benchmark policies.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if kyverno CLI is installed
command -v kyverno >/dev/null 2>&1 || { echo >&2 "kyverno CLI not found. Please install it (https://kyverno.io/docs/kyverno-cli/). Aborting."; exit 1; }

# Check if a resource directory path is provided as an argument

# Define relative paths based on the script's location
SCRIPT_DIR=$(dirname "$0")
POLICY_DIR="$SCRIPT_DIR/../kyverno-policies/cis/"

# Validate that the policy directory exists
if [ ! -d "$POLICY_DIR" ]; then
  echo "Error: Policy directory '$POLICY_DIR' not found." >&2
  exit 1
fi

echo "Validating resources in $RESOURCE_DIR against CIS policies in $POLICY_DIR..."

# Run Kyverno test command
kyverno test "$POLICY_DIR"

echo "Validation complete."

exit 0