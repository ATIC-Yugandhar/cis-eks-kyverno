#!/bin/bash
set -euo pipefail

if [ -d "terraform/compliant" ]; then
  echo "[INFO] Destroying compliant stack..."
  terraform -chdir=terraform/compliant destroy -auto-approve || true
fi

if [ -d "terraform/noncompliant" ]; then
  echo "[INFO] Destroying noncompliant stack..."
  terraform -chdir=terraform/noncompliant destroy -auto-approve || true
fi

echo "[INFO] Cleanup complete."