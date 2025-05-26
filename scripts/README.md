# CIS EKS Kyverno Scripts

This directory contains scripts for testing and validating CIS EKS compliance using Kyverno policies.

## 📁 Script Organization

### Core Test Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `test-all.sh` | Master script that runs all test types | `./test-all.sh [OPTIONS]` |
| `test-kubernetes-policies.sh` | Tests Kubernetes/unit policies | `./test-kubernetes-policies.sh [--ci] [--filter PATTERN]` |
| `test-terraform-policies.sh` | Tests Terraform policies | `./test-terraform-policies.sh [--compliant-only] [--noncompliant-only]` |
| `test-kind-cluster.sh` | End-to-end testing with Kind cluster | `./test-kind-cluster.sh [--keep] [--skip-create]` |

### Utility Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `kyverno-test-wrapper.sh` | Wrapper for Kyverno tests (handles audit mode) | Used internally by test scripts |
| `cleanup.sh` | General cleanup utility | `./cleanup.sh` |
| `cleanup-old-reports.sh` | Removes old test reports | `./cleanup-old-reports.sh [DAYS]` |
| `generate-summary-report.sh` | Generates executive summaries | `./generate-summary-report.sh` |
| `cluster-resource-scan.sh` | Scans cluster resources | `./cluster-resource-scan.sh` |

## 🚀 Quick Start

### Run All Tests
```bash
./test-all.sh
```

### Run Specific Test Types
```bash
# Only Kubernetes policy tests
./test-all.sh --kubernetes-only

# Only Terraform tests
./test-all.sh --terraform-only

# Only Kind cluster tests
./test-all.sh --cluster-only

# Skip cluster tests (faster)
./test-all.sh --skip-cluster
```

### Individual Test Scripts

#### Kubernetes Policy Tests
```bash
# Run all Kubernetes tests
./test-kubernetes-policies.sh

# Run in CI mode (simplified output)
./test-kubernetes-policies.sh --ci

# Filter tests by pattern
./test-kubernetes-policies.sh --filter custom-5.1
```

#### Terraform Policy Tests
```bash
# Test both compliant and non-compliant
./test-terraform-policies.sh

# Test only compliant configuration
./test-terraform-policies.sh --compliant-only

# Skip terraform init (use existing plan)
./test-terraform-policies.sh --skip-init
```

#### Kind Cluster Tests
```bash
# Full test cycle (create, test, cleanup)
./test-kind-cluster.sh

# Keep cluster running after tests
./test-kind-cluster.sh --keep

# Use existing cluster
./test-kind-cluster.sh --skip-create

# Only cleanup
./test-kind-cluster.sh --cleanup-only
```

## 📊 Test Reports

All test reports are generated in the `reports/` directory:

- **Kubernetes Tests**: `reports/policy-tests/`
  - `summary.md` - Test summary
  - `detailed-results.md` - Detailed results
  - `execution-stats.json` - Execution statistics

- **Terraform Tests**: `reports/terraform-compliance/`
  - `compliant-plan-scan.md` - Compliant configuration results
  - `noncompliant-plan-scan.md` - Non-compliant configuration results

- **Kind Cluster Tests**: `reports/kind-cluster/`
  - `test-results.md` - Test results
  - `cluster-resources.yaml` - Exported cluster resources

- **Comprehensive Reports**: `reports/comprehensive/`
  - `comprehensive-summary.md` - Overall summary when running all tests

## 🛠️ Dependencies

Required tools:
- `kyverno` - Kyverno CLI
- `kubectl` - Kubernetes CLI
- `terraform` - Terraform CLI (for Terraform tests)
- `docker` - Docker (for Kind cluster tests)
- `kind` - Kubernetes in Docker (auto-installed if missing)

## 🔧 Configuration

Environment variables:
- `CI=true` - Run in CI mode (simplified output)
- `CLUSTER_NAME` - Custom Kind cluster name (default: `cis-eks-kyverno-test`)

## 📝 Notes

1. **Audit Mode**: All policies are in audit mode by default, which means they log violations but don't block resources. This is why the `kyverno-test-wrapper.sh` is needed to properly detect test failures.

2. **Test Organization**: Tests are organized by type:
   - Unit tests validate individual policy behavior
   - Terraform tests validate infrastructure as code
   - Kind cluster tests validate runtime behavior

3. **Performance**: Running all tests can take several minutes. Use `--skip-cluster` for faster feedback during development.

## 🐛 Troubleshooting

If tests are failing:

1. **Check dependencies**: Ensure all required tools are installed
2. **Review logs**: Check detailed reports in the `reports/` directory
3. **Audit mode**: Remember that policies in audit mode won't block resources
4. **Clean state**: Run `./cleanup.sh` to clean up any stale resources

## 📚 Additional Resources

- [Kyverno Documentation](https://kyverno.io/docs/)
- [CIS EKS Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [Project README](../README.md)