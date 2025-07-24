# CIS EKS Kyverno Compliance Framework

[![Tests](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/workflows/Comprehensive%20CIS%20EKS%20Compliance%20Tests/badge.svg)](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/actions)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-1.6+-purple.svg)](https://opentofu.org/)
[![Kyverno](https://img.shields.io/badge/Kyverno-1.13+-green.svg)](https://kyverno.io/)
[![Compliance](https://img.shields.io/badge/Compliance-99%25-brightgreen.svg)](reports/executive-summary.md)

> **🚀 Comprehensive CIS Amazon EKS Benchmark v1.7.0 implementation with streamlined compliance validation through Kyverno policies and integrated node-level security scanning.**

## 🎯 Key Achievements

- **🛡️ Complete Coverage**: All 64 CIS benchmark controls implemented and validated
- **🔧 Integrated Node Scanner**: Custom DaemonSet performs filesystem and configuration checks
- **📊 99% Compliance Rate**: 123 out of 124 tests passing in production
- **🏗️ Pre-deployment Validation**: OpenTofu/Terraform plans validated before infrastructure creation
- **📋 Structured Reporting**: JSON-based results enable automated compliance tracking
- **⚡ Rapid Validation**: Complete test suite executes in ~12 seconds

## 🚦 Current Status

| Component | Status | Coverage | Details |
|-----------|--------|----------|---------|
| **Kubernetes Policies** | ✅ 99% Pass | 41 policies | Resource and node-level validation |
| **OpenTofu/Terraform** | ✅ 100% Pass | 23 policies | Infrastructure as Code validation |
| **Node Security Scanner** | ✅ Operational | 13 checks | Filesystem and kubelet validation |
| **Overall Compliance** | ✅ 99% | 64 policies | One known RBAC edge case |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  KYVERNO POLICY ENGINE                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────┐ │
│  │  Kubernetes  │    │  OpenTofu/   │    │   Node   │ │
│  │  Resources   │    │  Terraform   │    │ Security │ │
│  │  Validation  │    │    Plans     │    │ Scanner  │ │
│  └──────┬───────┘    └──────┬───────┘    └────┬─────┘ │
│         │                    │                  │       │
│         ▼                    ▼                  ▼       │
│  ┌────────────────────────────────────────────────┐    │
│  │        Comprehensive Policy Validation         │    │
│  │  • Admission Control  • JSON Scanning          │    │
│  │  • ConfigMap Analysis • CEL Expressions        │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (EKS, Kind, or compatible)
- kubectl configured
- Kyverno CLI v1.13.6+
- OpenTofu/Terraform (optional, for IaC validation)

### Installation

```bash
# 1. Clone repository
git clone https://github.com/ATIC-Yugandhar/cis-eks-kyverno.git
cd cis-eks-kyverno

# 2. Install Kyverno in cluster
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.13.6/install.yaml

# 3. Apply RBAC permissions
kubectl apply -f kyverno-node-rbac.yaml

# 4. Deploy node security scanner
kubectl apply -f k8s/cis-scanner-pod.yaml

# 5. Apply all policies
kubectl apply -f policies/kubernetes/ -R
```

### Testing

```bash
# Test all Kubernetes policies
./scripts/test-kubernetes-policies.sh

# Test OpenTofu/Terraform policies
./scripts/test-opentofu-policies.sh

# Run full integration test with Kind
./scripts/test-kind-cluster.sh

# Generate compliance report
./scripts/generate-summary-report.sh
```

## 📁 Project Structure

```
cis-eks-kyverno/
├── k8s/
│   └── cis-scanner-pod.yaml      # Node security scanner DaemonSet
├── policies/
│   ├── kubernetes/               # 41 Kubernetes policies
│   │   ├── control-plane/        # API server, audit logs
│   │   ├── pod-security/         # Security standards
│   │   ├── rbac/                 # Access control
│   │   ├── scanner/              # Scanner validation
│   │   └── worker-nodes/         # Node security (13 policies)
│   └── opentofu/                 # 23 IaC policies
│       ├── cluster-config/       # Cluster settings
│       ├── encryption/           # KMS, secrets
│       ├── monitoring/           # Logging, scanning
│       ├── networking/           # Network security
│       └── rbac/                 # IAM policies
├── scripts/                      # Testing & reporting
├── tests/                        # Test scenarios
└── reports/                      # Compliance reports
```

## 🔍 Node Security Scanner

The integrated security scanner performs critical node-level checks:

### Key Features
- **DaemonSet Deployment**: Automatically runs on all nodes
- **JSON Output Format**: Machine-readable results for policy validation
- **Comprehensive Checks**: Covers all 13 CIS worker node controls
- **ConfigMap Storage**: Results accessible for Kyverno validation

### Security Checks
```
3.1.1 - Kubeconfig file permissions (644 or more restrictive)
3.1.2 - Kubeconfig file ownership (root:root)
3.1.3 - Kubelet config file permissions
3.1.4 - Kubelet config file ownership
3.2.1 - Anonymous authentication disabled
3.2.2 - Authorization mode not AlwaysAllow
3.2.3 - Client CA file configured
3.2.4 - Read-only port disabled
3.2.5 - Streaming connection timeout set
3.2.6 - Protect kernel defaults enabled
3.2.7 - Make iptables util chains
3.2.8 - Hostname override not set
3.2.9 - Event record QPS appropriate
```

## 📊 Compliance Results

### Summary
- **Total Policies**: 64
- **Tests Executed**: 124
- **Passed**: 123 (99%)
- **Failed**: 1 (custom-4.5.1)
- **Execution Time**: ~12 seconds

### By Category
| Category | Policies | Pass Rate | Notes |
|----------|----------|-----------|-------|
| Control Plane | 2 | 100% | Audit logs, API server |
| Pod Security | 9 | 100% | Container security |
| RBAC | 15 | 93% | One known issue |
| Worker Nodes | 13 | 100% | Scanner validated |
| OpenTofu | 23 | 100% | IaC validation |

## 🛠️ Advanced Usage

### OpenTofu/Terraform Validation
```bash
# Validate compliant infrastructure
KYVERNO_EXPERIMENTAL=true kyverno json scan \
  --policy policies/opentofu/example.yaml \
  --payload opentofu/compliant/tofuplan.json

# Test non-compliant plans
KYVERNO_EXPERIMENTAL=true kyverno json scan \
  --policy policies/opentofu/example.yaml \
  --payload opentofu/noncompliant/tofuplan.json
```

### Scanner Output Format
```yaml
# Scanner results in JSON format
{
  "node": "worker-1",
  "timestamp": "2025-01-23T12:00:00Z",
  "scanner": "custom-cis-scanner",
  "version": "1.0.0",
  "checks": [
    {
      "id": "3.1.1",
      "description": "Ensure kubeconfig file permissions",
      "status": "PASS"
    }
  ]
}
```

## 🚀 Framework Benefits

1. **Streamlined Implementation**
   - Centralized policy management
   - Consistent validation methodology
   - Integrated compliance reporting

2. **Operational Efficiency**
   - Minimal external dependencies
   - Standardized output formats
   - Automated validation workflows

3. **Enterprise Ready**
   - Native Kubernetes integration
   - GitOps compatible design
   - CI/CD pipeline support

4. **Simplified Maintenance**
   - Consolidated updates
   - Unified troubleshooting
   - Comprehensive documentation

## 🤝 Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new policies
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- CIS Kubernetes Benchmark v1.7.0
- Kyverno community
- CNCF for supporting cloud-native security

## 📞 Support

- [GitHub Issues](https://github.com/ATIC-Yugandhar/cis-eks-kyverno/issues)
- [Policy Documentation](policies/README.md)

---

**Note**: This framework provides a streamlined approach to CIS compliance validation, reducing operational complexity while maintaining comprehensive security coverage.