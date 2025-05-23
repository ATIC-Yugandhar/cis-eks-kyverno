# 🛠️ CIS EKS Compliance Automation Scripts

This directory contains comprehensive automation scripts for validating CIS EKS compliance using Kyverno policies across multiple environments and scenarios.

## 🚀 Quick Start

```bash
# Run all tests (recommended)
./run-comprehensive-tests.sh

# Run specific test types
./test-all-policies.sh              # Unit tests only
./kind-cluster-validate.sh          # Kind cluster tests only
./cluster-resource-scan.sh           # Scan existing cluster
```

## 📋 Prerequisites

### Required Tools
- **Kyverno CLI** - [Installation Guide](https://kyverno.io/docs/installation/)
- **kubectl** - Kubernetes CLI
- **Docker** - For Kind cluster tests
- **Terraform** - For infrastructure validation
- **curl** - For downloading dependencies

### Optional Tools (Auto-installed)
- **Kind** - Kubernetes in Docker (auto-installed if missing)
- **yq** - YAML processor (auto-installed if missing)

## 🧪 Core Test Scripts

### 1. `run-comprehensive-tests.sh` - **Main Test Suite**
Orchestrates all test types with percentage-based reporting and comprehensive summaries.

```bash
# Run all tests
./run-comprehensive-tests.sh

# Customize test execution
RUN_KIND_CLUSTER_TESTS=false ./run-comprehensive-tests.sh
RUN_CLUSTER_SCAN=true CLUSTER_CONTEXT=production ./run-comprehensive-tests.sh
```

**Features:**
- 🎯 Percentage-based progress tracking
- 📊 Comprehensive test coverage matrix
- 🔄 Configurable test suite execution
- 📈 Executive summary generation

### 2. `test-all-policies.sh` - **Unit Tests**
Validates individual Kyverno policies against test manifests.

```bash
./test-all-policies.sh
```

**Features:**
- ✅ 54 individual policy tests
- ⚡ Performance metrics (fastest/slowest tests)
- 📊 CIS section compliance breakdown
- 🎨 Real-time progress visualization

### 3. `kind-cluster-validate.sh` - **End-to-End Testing**
Creates a Kind cluster, deploys Kyverno, and validates policies against live resources.

```bash
./kind-cluster-validate.sh

# Keep cluster for debugging
KEEP_CLUSTER=true ./kind-cluster-validate.sh
```

**Features:**
- 🐳 Automated Kind cluster creation
- 🔧 Kyverno installation and configuration
- 🧪 Live policy enforcement testing
- 📋 Cluster resource extraction and scanning

### 4. `cluster-resource-scan.sh` - **Production Scanning**
Scans existing Kubernetes clusters for CIS EKS compliance.

```bash
# Scan current context
./cluster-resource-scan.sh

# Scan specific cluster and namespace
./cluster-resource-scan.sh production kube-system
```

**Features:**
- 🔍 Live cluster resource extraction
- 📊 CIS section violation breakdown
- 🎯 Namespace-specific scanning
- 📈 Compliance rate calculation

### 5. `test-terraform-cis-policies.sh` - **Infrastructure Validation**
Validates Terraform plans against CIS EKS policies.

```bash
./test-terraform-cis-policies.sh
```

**Features:**
- 🏗️ Terraform plan validation
- 📊 Compliant vs non-compliant comparison
- 🎯 Infrastructure-as-Code compliance
- 📈 Policy coverage statistics

## 📊 Validation Scripts

### Infrastructure Validation
- `compliant-validate.sh` - Validate compliant infrastructure
- `noncompliant-validate.sh` - Validate non-compliant infrastructure

### Reporting
- `generate-summary-report.sh` - Generate executive summaries
- `cleanup-old-reports.sh` - Clean up old test reports

## 🎯 Test Coverage Matrix

| Test Type | Coverage | Purpose | Runtime |
|-----------|----------|---------|---------|
| **Unit Tests** | 54 policies | Individual policy validation | ~15s |
| **Kind Cluster** | End-to-end | Live cluster validation | ~3-5min |
| **Terraform** | Infrastructure | Plan-time validation | ~30s |
| **Cluster Scan** | Production | Real environment audit | ~1-2min |

## 📈 Enhanced Features

### Percentage-Based Reporting
All scripts now include:
- Real-time progress indicators
- Success rate calculations
- Performance metrics
- Executive summaries

### Multi-Environment Support
- **Development**: Kind cluster testing
- **Staging**: Cluster resource scanning
- **Production**: Live compliance monitoring
- **CI/CD**: Automated validation

### Comprehensive Reporting
- 📊 Executive dashboards
- 📋 Detailed policy results
- 🎯 CIS section breakdowns
- ⚡ Performance analytics

## 🔧 Configuration

### Environment Variables

```bash
# Test execution control
export RUN_UNIT_TESTS=true
export RUN_TERRAFORM_TESTS=true
export RUN_KIND_CLUSTER_TESTS=true
export RUN_CLUSTER_SCAN=false

# Cluster configuration
export CLUSTER_CONTEXT=production
export KEEP_CLUSTER=false

# Reporting
export REPORT_DIR=reports/custom
```

### Script Customization

Most scripts support command-line arguments and environment variables for customization:

```bash
# Help for any script
./script-name.sh --help

# Example customizations
./cluster-resource-scan.sh my-cluster my-namespace
REPORT_DIR=/tmp/reports ./test-all-policies.sh
```

## 📁 Output Structure

```
reports/
├── comprehensive/           # Combined test results
├── policy-tests/           # Unit test results
├── kind-cluster/           # Kind cluster test results
├── cluster-scan/           # Live cluster scan results
├── terraform-compliance/   # Terraform validation results
└── executive-summary.md    # Overall summary
```

## 🚀 CI/CD Integration

### GitHub Actions
The repository includes a comprehensive GitHub Actions workflow:

```yaml
name: Comprehensive CIS EKS Compliance Tests
# Runs unit tests, Terraform validation, and Kind cluster tests
# Generates comprehensive reports and artifacts
```

### Local CI Simulation
```bash
# Simulate CI environment
export CI=true
./run-comprehensive-tests.sh
```

## 🔍 Troubleshooting

### Common Issues

1. **Kyverno CLI not found**
   ```bash
   # Install Kyverno CLI
   curl -LO https://github.com/kyverno/kyverno/releases/latest/download/kyverno-cli_linux_x86_64.tar.gz
   tar -xzf kyverno-cli_linux_x86_64.tar.gz
   sudo mv kyverno /usr/local/bin/
   ```

2. **Kind cluster creation fails**
   ```bash
   # Ensure Docker is running
   sudo systemctl start docker
   sudo usermod -aG docker $USER
   ```

3. **Tests fail with permission errors**
   ```bash
   # Make scripts executable
   chmod +x scripts/*.sh
   ```

### Debug Mode
Enable verbose output for troubleshooting:

```bash
export DEBUG=true
./script-name.sh
```

## 📚 References

- **CIS EKS Benchmark**: [Official Documentation](https://www.cisecurity.org/benchmark/kubernetes)
- **Kyverno**: [Official Documentation](https://kyverno.io/docs/)
- **Kind**: [Official Documentation](https://kind.sigs.k8s.io/)
- **Policy Details**: See `policies/README.md`
- **Test Cases**: See `tests/README.md`

---

*🤖 Enhanced CIS EKS Compliance Automation Suite v2.0*