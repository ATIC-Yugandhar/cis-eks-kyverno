#!/bin/bash
set -euo pipefail

COMPLIANT_DIR="terraform/compliant"
NONCOMPLIANT_DIR="terraform/noncompliant"

echo "Destroying compliant cluster..."
cd "$COMPLIANT_DIR"
terraform destroy -auto-approve
cd - > /dev/null

echo "Destroying non-compliant cluster..."
cd "$NONCOMPLIANT_DIR"
terraform destroy -auto-approve
cd - > /dev/null

# Remove any temporary files if needed (add patterns below)
# Example: rm -f /tmp/kyverno-*.tmp

echo "Cleanup complete."