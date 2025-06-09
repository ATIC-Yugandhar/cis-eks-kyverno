#!/bin/bash
set -euo pipefail

if [ -d "opentofu/compliant" ]; then
  echo "[INFO] Destroying compliant stack..."
  tofu -chdir=opentofu/compliant destroy -auto-approve || true
fi

if [ -d "opentofu/noncompliant" ]; then
  echo "[INFO] Destroying noncompliant stack..."
  tofu -chdir=opentofu/noncompliant destroy -auto-approve || true
fi

echo "[INFO] Cleanup complete."