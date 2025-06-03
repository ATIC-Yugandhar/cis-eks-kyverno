# Scripts Directory

This directory contains utility scripts for testing and managing the CIS EKS Kyverno policies.

## Scripts

### test-kubernetes-policies.sh
Main test runner that validates all Kubernetes and Terraform policies against test resources.
- Tests both compliant and non-compliant scenarios
- Generates comprehensive reports in `reports/policy-tests/`
- Used by GitHub Actions CI/CD pipeline

### test-terraform-policies.sh
Dedicated script for testing Terraform policies against Terraform plans.
- Tests both compliant and non-compliant Terraform configurations
- Generates reports in `reports/terraform-compliance/`

### test-kind-cluster.sh
Integration test script that creates a Kind cluster and tests policies in a real Kubernetes environment.
- Creates Kind cluster with Kyverno installed
- Applies all policies to the cluster
- Tests policy enforcement with sample resources
- Can skip cluster creation with `--skip-create` flag


### generate-summary-report.sh
Generates an executive summary report from all test results.
- Aggregates results from policy tests
- Creates `reports/executive-summary.md`

### cleanup.sh
Utility script to clean up Terraform state files and temporary resources.
- Removes `.terraform` directories
- Cleans up `tfplan.*` files
- Safe to run at any time

## Usage

```bash
# Run Kubernetes and Terraform policy tests
./scripts/test-kubernetes-policies.sh

# Run only Terraform policy tests
./scripts/test-terraform-policies.sh

# Run Kind cluster integration tests
./scripts/test-kind-cluster.sh

# Run Kind cluster tests without creating cluster
./scripts/test-kind-cluster.sh --skip-create

# Generate executive summary
./scripts/generate-summary-report.sh

# Clean up Terraform files
./scripts/cleanup.sh
```

## CI/CD Integration

The GitHub Actions workflow uses:
- `test-kubernetes-policies.sh` for unit tests (includes Terraform policies)
- `test-terraform-policies.sh` for dedicated Terraform compliance testing
- `test-kind-cluster.sh` for integration testing with a real Kubernetes cluster