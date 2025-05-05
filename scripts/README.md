# EKS CIS Benchmark Scripts

This directory contains utility scripts for the EKS CIS Benchmark project.

## Available Scripts

### cleanup-repo.sh

Cleans up the repository after the enhanced structure implementation:

- Removes redundant directories (`terraform/compliant` and `terraform/noncompliant`) now replaced by the enhanced structure
- Removes unnecessary comments and debug code from Terraform files, Python scripts, and shell scripts
- Provides a safer cleanup process with user confirmation

Usage:

```bash
./cleanup-repo.sh
```

### test-all-policies.sh

Runs tests for all Kyverno policies against a Kubernetes cluster:

```bash
export KUBECONFIG=/path/to/your/kubeconfig
./test-all-policies.sh
```

### compliant.sh and noncompliant.sh

Legacy deployment scripts for compliant and non-compliant clusters. These are kept for reference but the new approach uses the centralized configuration in the enhanced structure.

## Adding New Scripts

When adding new scripts to this directory:

1. Make them executable: `chmod +x scripts/your-script.sh`
2. Add documentation in this README file
3. Ensure they follow best practices for shell scripts (use `set -e`, provide help text, etc.)