# CIS EKS Kyverno Compliance Framework

A comprehensive framework for implementing and testing CIS benchmarks on Amazon EKS using Kyverno policies.

## 🌟 Enhanced Structure Overview

This repository has been enhanced with a new modular infrastructure that provides:

1. **Parameter-driven compliance controls**: A centralized configuration system maps CIS controls to specific Terraform settings
2. **Enhanced module structure**: Hierarchical modules for EKS cluster, networking, security, logging, and Kyverno integration
3. **Testing framework**: Automated validation of compliant and non-compliant configurations
4. **Reporting infrastructure**: Comprehensive compliance reporting and visualization
5. **CI/CD pipeline**: GitHub Actions workflows for automated testing and validation

## 📂 Repository Structure

```
.
├── bin/                        # CLI tools
│   └── eks-kyverno-test        # Unified workflow command-line tool
├── terraform/
│   ├── enhanced/               # Enhanced Terraform configurations
│   │   ├── compliant/          # Compliant EKS cluster configuration  
│   │   └── noncompliant/       # Non-compliant EKS cluster configuration
│   ├── modules/                # Terraform modules
│   │   ├── eks/               # Main orchestration module
│   │   ├── eks_cluster/       # Core EKS cluster deployment
│   │   ├── eks_config/        # Central configuration management
│   │   ├── eks_logging/       # Logging and monitoring
│   │   ├── eks_networking/    # Network configurations for EKS
│   │   ├── eks_security/      # Security configurations for EKS
│   │   ├── kyverno/           # Kyverno deployment and policies
│   │   └── reporting/         # Compliance reporting infrastructure
│   └── templates/              # Templates for resources
│       └── kyverno/           # Kyverno policy templates
├── kyverno-policies/           # Kyverno policies for CIS controls
├── tests/                      # Test scenarios
│   └── [control-id]/           # Test cases for each control
├── reports/                    # Generated compliance reports
│   ├── compliance/             # Compliance state reports
│   ├── comparison/             # Comparative analysis
│   ├── metrics/                # Performance and coverage metrics
│   └── dashboard/              # Interactive dashboards
└── scripts/                    # Utility scripts
```

## 🚀 Getting Started

### Quick Start

1. Clone the repository
2. Run the setup script:

```bash
cd terraform/enhanced
./setup.sh
```

3. Deploy a compliant cluster:

```bash
bin/eks-kyverno-test run --cluster-type compliant
```

### CLI Usage

The framework includes a CLI tool for managing the workflow:

```bash
# Deploy both cluster types and run all tests
bin/eks-kyverno-test run-all

# Deploy only compliant cluster and run specific tests
bin/eks-kyverno-test run --cluster-type compliant --tests cis-3.2.1,cis-4.1.1

# Run tests against existing clusters
bin/eks-kyverno-test test --compliant-kubeconfig ~/kubeconfig-compliant \
                        --noncompliant-kubeconfig ~/kubeconfig-noncompliant

# Generate comprehensive compliance report
bin/eks-kyverno-test report --output-format html,json,markdown

# Clean up resources
bin/eks-kyverno-test cleanup
```

## 🔒 CIS Controls Covered

This framework implements and tests the following CIS EKS Benchmark controls:

### Identity and Access Management

- Control plane authentication and authorization
- Pod Security Standards
- Service account management
- RBAC configuration

### Logging and Monitoring

- Control plane logging
- Audit logging retention
- Pod-level logging

### Network Security

- Network policy implementation
- Cluster endpoint access
- Service configuration

### Data Encryption

- Secrets encryption at rest
- TLS configuration
- Key management

## 📊 Reporting

The reporting infrastructure generates:

1. **Compliance reports**: Detailed compliance state for each cluster
2. **Comparison reports**: Side-by-side comparison of compliant vs. non-compliant clusters
3. **Metrics**: Policy effectiveness and coverage metrics
4. **Dashboards**: Interactive visualizations of compliance state

## 🔄 CI/CD Integration

The framework includes GitHub Actions workflows for:
- Test execution on PR/push
- Scheduled compliance checks
- Report generation and publishing

## 📦 Requirements

- Terraform v1.0+
- AWS CLI v2
- kubectl
- Kyverno CLI
- Python 3.8+

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a pull request.

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.