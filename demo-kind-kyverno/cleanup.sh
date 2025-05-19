#!/usr/bin/env bash
set -e

echo "Deleting Kind cluster 'demo'..."
kind delete cluster --name demo

echo "Cluster deleted."

# Also remove the reports directory
SCRIPT_DIR_CLEANUP="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPORTS_DIR_CLEANUP="$SCRIPT_DIR_CLEANUP/reports"
if [ -d "$REPORTS_DIR_CLEANUP" ]; then
  echo "Removing reports directory: $REPORTS_DIR_CLEANUP..."
  rm -rf "$REPORTS_DIR_CLEANUP"
  echo "Reports directory removed."
else
  echo "Reports directory ($REPORTS_DIR_CLEANUP) not found, skipping removal."
fi