# CIS EKS Kyverno Compliance Framework

[![Tests](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/workflows/Kyverno%20Policy%20and%20Plan%20Compliance%20Check/badge.svg)](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/actions)

A comprehensive, production-ready framework for implementing and validating **CIS Amazon EKS Benchmark** controls using **Kyverno policies**. This repository serves as the reference implementation for the ebook ["Enforcing CIS EKS Benchmark Compliance with Kyverno: A Comprehensive Guide"](ebook.md).

## 🎯 What This Framework Provides

- **🛡️ Complete CIS Coverage**: 56+ policies covering major CIS EKS Benchmark controls
- **🔄 Dual Enforcement Strategy**: Both runtime (Kubernetes) and plan-time (Terraform) validation  
- **📋 Automated Testing**: Comprehensive test suite with CI/CD integration
- **📊 Professional Reporting**: GitHub-friendly Markdown reports with visual indicators
- **🏗️ Production Examples**: Real-world configurations for compliant and non-compliant clusters
- **📚 Educational Resource**: Step-by-step guides and detailed documentation

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Kyverno CLI >= 1.11
- kubectl configured

### 30-Second Demo
```bash
# Clone and test
git clone https://github.com/ATIC-Yugandhar/cis-eks-kyverno.git
cd cis-eks-kyverno

# Run all policy tests
./tools/scripts/testing/test-all-policies.sh

# Run Terraform compliance tests  
./tools/scripts/testing/test-terraform-cis-policies.sh

# Generate executive summary
./tools/scripts/reporting/generate-summary-report.sh
```

## 📁 Repository Structure

```
cis-eks-kyverno/
├── 📚 docs/                    # Comprehensive documentation
│   ├── getting-started/        # Quick start guides
│   ├── architecture/           # Solution architecture  
│   ├── policies/               # Policy documentation
│   └── examples/               # Detailed walkthroughs
├── 🛡️ policies/                # Organized Kyverno policies
│   ├── kubernetes/             # Runtime policies by CIS section
│   │   ├── control-plane/      # Section 2: Control Plane
│   │   ├── worker-nodes/       # Section 3: Worker Nodes
│   │   ├── rbac/              # Section 4: RBAC & Service Accounts
│   │   └── pod-security/      # Section 5: Pod Security
│   └── terraform/             # Plan-time policies by component
│       ├── cluster-config/     # EKS cluster configuration
│       ├── networking/         # VPC and networking
│       ├── encryption/         # KMS and encryption
│       └── monitoring/         # Logging and monitoring
├── 🧪 tests/                   # Comprehensive test cases
├── 📝 examples/                # Working examples
│   ├── basic-setup/           # Simple getting started
│   ├── production-ready/      # Enterprise-grade example
│   └── custom-scenarios/      # Additional use cases
├── 🔧 tools/                   # Automation and utilities
│   ├── scripts/               # Organized automation scripts
│   ├── terraform/             # Infrastructure modules
│   └── ci-cd/                 # CI/CD configurations
└── 📊 reports/                 # Generated compliance reports
```

## 🏁 Getting Started Paths

Choose your learning path based on your goals:

### 🎓 **Learning & Education**
→ Start with [docs/getting-started/](docs/getting-started/) → Try [examples/basic-setup/](examples/basic-setup/)

### 🏭 **Production Implementation**  
→ Review [docs/architecture/](docs/architecture/) → Adapt [examples/production-ready/](examples/production-ready/)

### 🔧 **Development & Contributing**
→ See [docs/contributing/](docs/contributing/) → Review [tools/](tools/)

### 📖 **Ebook Readers**
→ Each ebook chapter maps to repository sections → Follow chapter-by-chapter

## 🛡️ Dual Enforcement Strategy

This framework implements a comprehensive **"shift-left"** security approach:

### 1. **Plan-Time Validation** (Prevention)
- Validate Terraform configurations before deployment
- Catch misconfigurations early in development
- Policies scan Infrastructure as Code for CIS compliance
- **Location**: `policies/terraform/`

### 2. **Runtime Validation** (Detection)  
- Validate live Kubernetes resources in EKS clusters
- Continuous compliance monitoring
- Policies enforce security standards on running workloads
- **Location**: `policies/kubernetes/`

## 📋 CIS EKS Benchmark Coverage

| CIS Section | Policies | Runtime | Plan-Time | Status |
|-------------|----------|---------|-----------|--------|
| **2. Control Plane** | 2 | ✅ | ✅ | Complete |
| **3. Worker Nodes** | 13 | ✅ | ⚠️ | Mostly Complete |
| **4. RBAC & Service Accounts** | 5 | ✅ | ⚠️ | Complete |
| **5. Pod Security** | 9 | ✅ | ✅ | Complete |

**Legend**: ✅ Fully Supported | ⚠️ Partially Supported | ❌ Not Applicable

See [docs/policies/mapping.md](docs/policies/mapping.md) for detailed coverage analysis.

## 🧪 Testing & Validation

### Automated Testing
- **56 policy tests** with positive/negative scenarios
- **CI/CD integration** with GitHub Actions
- **Markdown reports** with visual pass/fail indicators
- **Executive summaries** for management reporting

### Test Execution
```bash
# Test all policies (unit tests)
./tools/scripts/testing/test-all-policies.sh

# Test Terraform compliance (integration tests)  
./tools/scripts/testing/test-terraform-cis-policies.sh

# Generate comprehensive reports
./tools/scripts/reporting/generate-summary-report.sh
```

## 📊 Professional Reporting

Generated reports include:

- **📈 Executive Summary** - High-level compliance dashboard
- **📋 Policy Test Results** - Detailed test outcomes with visual indicators  
- **🛠️ Terraform Compliance** - Infrastructure validation results
- **📊 Trend Analysis** - Historical compliance tracking

All reports are GitHub-friendly Markdown with emojis and tables for professional presentation.

## 🌟 What Makes This Framework Unique

1. **📚 Educational Focus**: Designed as a learning resource with comprehensive documentation
2. **🏭 Production Ready**: Real-world examples suitable for enterprise deployment
3. **🔄 Dual Strategy**: Both prevention (plan-time) and detection (runtime) approaches
4. **🧪 Test-Driven**: Every policy has comprehensive test coverage
5. **📊 Professional Reporting**: Publication-quality compliance reports
6. **🔧 Extensible**: Modular design for easy customization and extension

## 🤝 Contributing

We welcome contributions! See [docs/contributing/](docs/contributing/) for:

- Development setup and guidelines
- Testing standards and procedures  
- Code style and conventions
- How to add new policies or examples

## 📖 Related Resources

- **[Ebook](ebook.md)**: "Enforcing CIS EKS Benchmark Compliance with Kyverno"
- **[CIS EKS Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)**: Official CIS guidelines
- **[Kyverno Documentation](https://kyverno.io/docs/)**: Official Kyverno docs
- **[AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)**: AWS security guidance

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## ⭐ Star History

If you find this framework useful, please consider starring the repository to help others discover it!

---

**🎯 Ready to get started?** → [docs/getting-started/](docs/getting-started/)

**❓ Need help?** → [docs/examples/troubleshooting.md](docs/examples/troubleshooting.md)

**💡 Want to contribute?** → [docs/contributing/](docs/contributing/)