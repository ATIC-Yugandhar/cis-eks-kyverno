# CIS EKS Kyverno Compliance Framework

[![Tests](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/workflows/Comprehensive%20CIS%20EKS%20Compliance%20Tests/badge.svg)](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/actions)
[![Tests Status](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/workflows/Comprehensive%20CIS%20EKS%20Compliance%20Tests/badge.svg?branch=main)](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/actions?query=branch%3Amain)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-1.6+-purple.svg)](https://opentofu.org/)
[![Kyverno](https://img.shields.io/badge/Kyverno-1.13+-green.svg)](https://kyverno.io/)

A comprehensive, production-ready framework for implementing and validating **CIS Amazon EKS Benchmark** controls using **Kyverno policies**. This repository provides complete CIS compliance automation with both runtime and plan-time validation.

## 🚦 Workflow Status

The badges above show the current status of our comprehensive test suite:

- **Tests**: Overall workflow status across all test types
- **Tests Status**: Main branch specific status
- **License**: Apache 2.0 open source license
- **OpenTofu**: Compatible OpenTofu version
- **Kyverno**: Required Kyverno version

### Test Coverage
Our automated testing includes:
- **62 Policy Unit Tests**: Validate individual policy logic
- **Plan-Time Validation**: OpenTofu infrastructure scanning
- **Kind Cluster Integration**: Real Kubernetes cluster testing
- **Security Scanning**: Vulnerability detection with Trivy

## 🎯 What This Framework Provides

- **🛡️ Complete CIS Coverage**: 62 policies covering major CIS EKS Benchmark controls
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
│   └── opentofu/              # Plan-time policies by component (OpenTofu compatible)
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
├── 🏗️ opentofu/               # OpenTofu examples
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

## 🛡️ Multi-Tool Compliance Strategy

This framework implements a comprehensive **"defense-in-depth"** approach using multiple specialized tools:

### 1. **Plan-Time Validation** (Prevention)
- **Tool**: OpenTofu + Kyverno
- Validate Infrastructure as Code before deployment
- Catch misconfigurations early in development
- Policies scan Infrastructure as Code for CIS compliance
- **Location**: `policies/opentofu/`

### 2. **Runtime Validation** (Detection)
- **Tool**: Kyverno
- Validate live Kubernetes resources in EKS clusters
- Continuous compliance monitoring for API-accessible resources
- **Location**: `policies/kubernetes/`

### 3. **Node-Level Validation** (Deep Inspection) ⚠️
- **Tool**: Kube-bench (Required for complete coverage)
- Validate worker node file systems and kubelet configurations
- Essential for file permissions, ownership, and node-level settings
- **Integration**: Required for comprehensive CIS compliance

### ⚠️ Important: Tool Boundaries and Limitations

**Kyverno Limitations:**
- ❌ Cannot access worker node file systems
- ❌ Cannot validate file permissions or ownership
- ❌ Cannot read kubelet configuration files directly
- ✅ Validates Kubernetes API resources (Pods, RBAC, etc.)

**Kube-bench Integration Required:**
Most worker node controls (Section 3) require kube-bench for complete validation because they involve:
- File permissions on kubeconfig and kubelet config files
- Kubelet command-line arguments and configuration
- System-level security settings on worker nodes

See our [Worker Node Policy Documentation](policies/README.md#important-worker-node-policy-limitations) for detailed explanations.

## 📋 CIS EKS Benchmark Coverage

| CIS Section | Policies | Kyverno | Kube-bench | Plan-Time | Status |
|-------------|----------|---------|------------|-----------|--------|
| **2. Control Plane** | 2 | ✅ | ⚠️ | ✅ | Complete |
| **3. Worker Nodes** | 13 | ⚠️ | ✅ Required | ⚠️ | **Hybrid Approach** |
| **4. RBAC & Service Accounts** | 15 | ✅ | ❌ | ⚠️ | Complete |
| **5. Pod Security** | 9 | ✅ | ❌ | ✅ | Complete |

**Legend**:
- ✅ Fully Supported
- ⚠️ Partially Supported
- ❌ Not Applicable
- **✅ Required** Essential for complete validation

### ⚠️ Worker Nodes Section 3: Hybrid Validation Required

**Why both tools are needed:**
- **Kyverno**: Validates Pod security contexts, RBAC bindings, resource limits
- **Kube-bench**: Validates file permissions, kubelet config, node-level settings
- **Combined**: Provides comprehensive coverage of all CIS Section 3 controls

All worker node policies include detailed annotations explaining:
- What Kyverno validates vs. what requires kube-bench
- Specific kube-bench integration requirements
- Validation scope and limitations

See [policies/README.md](policies/README.md) for detailed policy organization and structure.

## 🧪 Testing & Validation

### Automated Testing
- **62 policy tests** with positive/negative scenarios
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
3. **🛡️ Multi-Tool Strategy**: Honest approach combining Kyverno + kube-bench for complete coverage
4. **⚠️ Transparent Limitations**: Clear documentation of what each tool can and cannot validate
5. **🧪 Test-Driven**: Every policy has comprehensive test coverage
6. **📊 Professional Reporting**: Publication-quality compliance reports
7. **🔧 Extensible**: Modular design for easy customization and extension
8. **🎯 Realistic Approach**: Acknowledges the need for multiple tools for comprehensive CIS compliance

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
