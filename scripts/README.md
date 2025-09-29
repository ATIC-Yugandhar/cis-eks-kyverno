# Scripts Directory

This directory contains utility scripts for testing and managing the CIS EKS Kyverno policies.

## Scripts

### test-kubernetes-policies.sh
Main test runner that validates all Kubernetes and OpenTofu policies against test resources.
- Tests both compliant and non-compliant scenarios
- Generates comprehensive reports in `reports/policy-tests/`
- Used by GitHub Actions CI/CD pipeline

### test-opentofu-policies.sh
Dedicated script for testing OpenTofu policies against plan files.
- Tests both compliant and non-compliant OpenTofu configurations
- Generates reports in `reports/opentofu-compliance/`

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
Utility script to destroy OpenTofu infrastructure resources.
- Runs `tofu destroy` on compliant and noncompliant stacks
- Safe to run at any time (uses `-auto-approve`)

## Usage

```bash
# Run Kubernetes and OpenTofu policy tests
./scripts/test-kubernetes-policies.sh

# Run only OpenTofu policy tests
./scripts/test-opentofu-policies.sh

# Run Kind cluster integration tests
./scripts/test-kind-cluster.sh

# Run Kind cluster tests without creating cluster
./scripts/test-kind-cluster.sh --skip-create

# Generate executive summary
./scripts/generate-summary-report.sh

# Clean up OpenTofu files
./scripts/cleanup.sh
```

## CI/CD Integration

The GitHub Actions workflow "Comprehensive CIS EKS Compliance Tests" uses:
- `test-kubernetes-policies.sh` for unit tests (includes OpenTofu policies)
- `test-opentofu-policies.sh` for dedicated OpenTofu compliance testing
- `test-kind-cluster.sh` for integration testing with a real Kubernetes cluster

### Workflow Status
The workflow runs on:
- Push to main and develop branches
- Pull requests to main
- Daily schedule (2 AM UTC)
- Manual dispatch via GitHub Actions UI

### Test Requirements
- **OpenTofu Tests**: Require `tofuplan.json` files in `opentofu/compliant/` and `opentofu/noncompliant/`
- **Kind Tests**: Require Docker and Kind to create test cluster
- **Unit Tests**: Only require Kyverno CLI