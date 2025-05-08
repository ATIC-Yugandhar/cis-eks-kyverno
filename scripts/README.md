# Automation Scripts

This folder contains automation scripts for validating CIS EKS compliance at the Terraform plan level using Kyverno JSON policies.

## Main Script: test-terraform-cis-policies.sh

This script automates the following workflow:

1. Generates Terraform plans for both the compliant and noncompliant EKS stacks.
2. Converts the plans to JSON format.
3. Runs all Kyverno JSON policies (from `kyverno-policies/terraform/`) against each plan using `kyverno-json`.
4. Writes results to `reports/compliance/` for both stacks.

### Usage

```sh
./test-terraform-cis-policies.sh
```

- Requires: Terraform, kyverno-json CLI, and AWS credentials for planning.

## Other Scripts
- `test-all-policies.sh`: Runs Kyverno tests for all test cases in the `tests/` folder (if present).
- `compliant-validate.sh`, `noncompliant-validate.sh`: Validate individual stacks.
- `cleanup.sh`: Clean up generated files and plans.

## References
- See `kyverno-policies/terraform/README.md` for policy details.
- See `terraform/compliant/README.md` and `terraform/noncompliant/README.md` for stack documentation. 