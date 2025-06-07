# CIS EKS Kyverno Compliance Framework

[![Tests](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/workflows/Kyverno%20Policy%20and%20Plan%20Compliance%20Check/badge.svg)](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/actions)

A comprehensive, production-ready framework for implementing and validating **CIS Amazon EKS Benchmark** controls using **Kyverno policies**. This repository provides complete CIS compliance automation with both runtime and plan-time validation.

## 🎯 What This Framework Provides

- **🛡️ Complete CIS Coverage**: 45 policies covering major CIS EKS Benchmark controls
- **🔄 Dual Enforcement Strategy**: Both runtime (Kubernetes) and plan-time (OpenTofu) validation  
- **📋 Automated Testing**: Comprehensive test suite with CI/CD integration
- **📊 Professional Reporting**: GitHub-friendly Markdown reports with visual indicators
- **🏗️ Production Examples**: Real-world configurations for compliant and non-compliant clusters
- **📚 Educational Resource**: Step-by-step guides and detailed documentation

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- OpenTofu >= 1.6.0 (or Terraform >= 1.0 for legacy support)
- Kyverno CLI >= 1.11
- kubectl configured
- **RBAC permissions**: Cluster-admin access (for RBAC setup)

### 30-Second Demo
```bash
# Clone and test
git clone https://github.com/ATIC-Yugandhar/cis-eks-kyverno.git
cd cis-eks-kyverno

# Run all policy tests
./scripts/test-kubernetes-policies.sh

# Run OpenTofu compliance tests  
./scripts/test-opentofu-policies.sh

# Generate executive summary
./scripts/generate-summary-report.sh
```

## ⚙️ Important Setup: Kyverno RBAC

Our policies validate Node resources, which requires additional RBAC permissions. **Apply this after installing Kyverno:**

```bash
# Apply RBAC fix for Node access permissions
kubectl apply -f kyverno-node-rbac.yaml
```

**Why this is needed:** Some CIS controls validate worker node configurations, requiring Kyverno to read Node resources.

## 📁 Repository Structure

```
cis-eks-kyverno/
├── 📚 docs/                    # Documentation
│   └── README.md              # Documentation overview
├── 🛡️ policies/                # Organized Kyverno policies
│   ├── kubernetes/             # Runtime policies by CIS section
│   │   ├── control-plane/      # Section 2: Control Plane
│   │   ├── worker-nodes/       # Section 3: Worker Nodes
│   │   ├── rbac/              # Section 4: RBAC & Service Accounts
│   │   └── pod-security/      # Section 5: Pod Security
│   └── terraform/             # Plan-time policies by component (works with OpenTofu)
│       ├── cluster-config/     # EKS cluster configuration
│       ├── networking/         # VPC and networking
│       ├── encryption/         # KMS and encryption
│       └── monitoring/         # Logging and monitoring
├── 🧪 tests/                   # Comprehensive test cases
│   ├── kind-manifests/        # Kind cluster test resources
│   └── kubernetes/            # Policy-specific test cases
├── 🔧 scripts/                 # Automation scripts
│   ├── test-kubernetes-policies.sh  # Main policy test runner
│   ├── test-opentofu-policies.sh    # OpenTofu compliance tests
│   ├── test-kind-cluster.sh         # Kind integration tests
│   ├── generate-summary-report.sh   # Report generation
│   └── cleanup.sh                   # Cleanup utilities
├── 🏗️ opentofu/               # OpenTofu examples (Terraform compatible)
│   ├── compliant/             # CIS-compliant configurations
│   └── noncompliant/          # Non-compliant configurations for testing
└── 📊 reports/                 # Generated compliance reports (created by scripts)
```

## 🏁 Getting Started Paths

Choose your learning path based on your goals:

### 🎓 **Learning & Education**
→ Start with [policies/README.md](policies/README.md) for policy structure → Try [tests/](tests/) examples

### 🏭 **Production Implementation**
→ Review [opentofu/compliant/](opentofu/compliant/) → Adapt policies from [policies/](policies/)

### 🔧 **Development & Contributing**
→ See [docs/README.md](docs/README.md) → Review [scripts/](scripts/) for automation

## 🛡️ Dual Enforcement Strategy

This framework implements a comprehensive **"shift-left"** security approach:

### 1. **Plan-Time Validation** (Prevention)
- Validate OpenTofu/Terraform configurations before deployment
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
| **4. RBAC & Service Accounts** | 15 | ✅ | ⚠️ | Complete |
| **5. Pod Security** | 9 | ✅ | ✅ | Complete |

**Legend**: ✅ Fully Supported | ⚠️ Partially Supported | ❌ Not Applicable

See [policies/README.md](policies/README.md) for detailed policy organization and structure.

## 🧪 Testing & Validation

### Automated Testing
- **56 policy tests** with positive/negative scenarios
- **CI/CD integration** with GitHub Actions
- **Markdown reports** with visual pass/fail indicators
- **Executive summaries** for management reporting

### Test Execution
```bash
# Test all policies (unit tests)
./scripts/test-kubernetes-policies.sh

# Test OpenTofu compliance (integration tests)
./scripts/test-opentofu-policies.sh

# Test with Kind cluster (integration tests)
./scripts/test-kind-cluster.sh

# Generate comprehensive reports
./scripts/generate-summary-report.sh
```

## 📊 Professional Reporting

Generated reports include:

- **📈 Executive Summary** - High-level compliance dashboard
- **📋 Policy Test Results** - Detailed test outcomes with visual indicators  
- **🛠️ OpenTofu Compliance** - Infrastructure validation results
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

We welcome contributions! Please follow these guidelines:

- Review existing policies in [policies/](policies/) for patterns and conventions
- Add comprehensive test cases in [tests/](tests/) for new policies
- Use the provided scripts in [scripts/](scripts/) for testing
- Follow the naming convention: `custom-[section]-[control]-[description].yaml`
- Ensure both compliant and non-compliant test scenarios

## 📖 Related Resources

- **[CIS EKS Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)**: Official CIS guidelines
- **[Kyverno Documentation](https://kyverno.io/docs/)**: Official Kyverno docs
- **[AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)**: AWS security guidance

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## ⭐ Star History

If you find this framework useful, please consider starring the repository to help others discover it!

---

**🎯 Ready to get started?** → [policies/README.md](policies/README.md) for policy structure

**❓ Need help?** → [scripts/README.md](scripts/README.md) for testing guidance

**💡 Want to contribute?** → Review [policies/README.md](policies/README.md) for policy structure
