#!/bin/bash
set -e

echo "============================================"
echo "    Repository Cleanup Script"
echo "============================================"
echo ""
echo "This script will clean up the repository after the enhanced"
echo "structure implementation, removing redundant files and"
echo "unnecessary comments."
echo ""

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Confirm with the user
read -p "This will remove files and modify content. Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

echo "Starting cleanup..."

# Remove redundant directories now that we have the enhanced structure
echo "Removing redundant directories..."
rm -rf "$REPO_ROOT/terraform/compliant"
rm -rf "$REPO_ROOT/terraform/noncompliant"

# Remove unnecessary comments and debug code from files
echo "Cleaning up comments..."

# Function to clean comment blocks (multi-line debug comments not single-line doc comments)
cleanup_file_comments() {
  local file=$1
  if [[ -f "$file" ]]; then
    # Remove debug-related comment blocks but keep documentation comments
    # This is a simplified approach - for a real project you'd want a more sophisticated parser
    sed -i'.bak' '/^[[:space:]]*#.*DEBUG/d; /^[[:space:]]*\/\/.*DEBUG/d; /^[[:space:]]*\/\*.*DEBUG/,/\*\//d' "$file"
    rm -f "${file}.bak" # Remove backup files created by sed
  fi
}

# Clean all Terraform files
echo "Cleaning Terraform files..."
find "$REPO_ROOT/terraform" -type f -name "*.tf" | while read -r tf_file; do
  cleanup_file_comments "$tf_file"
done

# Clean all Python files
echo "Cleaning Python files..."
find "$REPO_ROOT" -type f -name "*.py" | while read -r py_file; do
  cleanup_file_comments "$py_file"
done

# Clean all shell scripts
echo "Cleaning shell scripts..."
find "$REPO_ROOT" -type f -name "*.sh" | while read -r sh_file; do
  cleanup_file_comments "$sh_file"
done

# Clean up the CLI tool
echo "Removing debug code from CLI tool..."
sed -i'.bak' '/DEBUG/d; /^[[:space:]]*print("DEBUG/d' "$REPO_ROOT/bin/eks-kyverno-test"
rm -f "${REPO_ROOT}/bin/eks-kyverno-test.bak"

echo "Cleanup complete!"