# Test Framework

This directory contains comprehensive test cases for validating CIS EKS compliance policies using Kyverno.

## Test Structure

### 📋 Test Scenarios

The test suite includes **40 test scenarios** organized by CIS EKS Benchmark control numbers:

#### Control Plane (Section 2)
- `custom-2.1.1/` - API server configuration
- `custom-2.1.2/` - API server audit settings

#### Worker Nodes (Section 3)
- `custom-3.1.1/` to `custom-3.1.4/` - Worker node configuration files
- `custom-3.2.1/` to `custom-3.2.9/` - Worker node kubelet configuration

#### RBAC (Section 4)
- `custom-4.1.7/`, `custom-4.1.8/` - Role-based access controls
- `custom-4.3.1/` - Namespace security
- `custom-4.4.2/` - Secret management
- `custom-4.5.1/` - Service account permissions
- `supported-4.1.1/` to `supported-4.1.6/` - Core RBAC policies
- `supported-4.2.1/` to `supported-4.2.4/` - Pod security RBAC

#### Pod Security (Section 5)
- `custom-5.1.1/` to `custom-5.1.3/` - Pod security standards
- `custom-5.3.1/` - Encryption requirements
- `custom-5.4.1/` to `custom-5.4.5/` - Network security
- `custom-5.5.1/` - Service account configuration

### 🏗️ Test Organization

Each test directory contains:
```
test-scenario/
├── compliant/          # Resources that should pass policy validation
│   ├── kyverno-test.yaml
│   └── [resource-files]
└── noncompliant/       # Resources that should fail policy validation
    ├── kyverno-test.yaml
    └── [resource-files]
```

### 🧪 Integration Test Manifests

The `kind-manifests/` directory contains resources for end-to-end testing:
- `namespace.yaml` - Test namespace definition
- `serviceaccount.yaml` - Service account for testing
- `compliant-pod.yaml` - Pod that passes all policies
- `noncompliant-pod.yaml` - Pod that violates policies

### 📝 Special Documentation

Some test scenarios include detailed README files explaining Kyverno CLI limitations:
- `custom-3.1.1/README.md` - Node resource validation challenges
- `custom-3.2.5/README.md` - Worker node specific policy testing
- `custom-3.2.6/README.md` - Kubelet configuration validation

## Usage

### Running Tests Locally

```bash
# Test all policies against compliant resources
./scripts/test-kubernetes-policies.sh

# Test specific category
kyverno apply policies/kubernetes/pod-security/ --resource tests/kubernetes/custom-5.1.1/compliant/

# Test with Kind cluster
./scripts/test-kind-cluster.sh
```

### Integration with CI/CD

The test framework is integrated into GitHub Actions workflow:
- Validates all 45 policies against 40 test scenarios
- Generates detailed compliance reports
- Runs end-to-end testing with Kind clusters

## Test Coverage

| CIS Section | Test Count | Policy Count | Coverage |
|-------------|------------|--------------|----------|
| Control Plane | 2 | 2 | 100% |
| Worker Nodes | 13 | 13 | 100% |
| RBAC | 20 | 20 | 100% |
| Pod Security | 9 | 9 | 100% |
| **Total** | **40** | **45** | **89%** |

*Note: Some policies cover multiple CIS controls, resulting in higher policy count than test scenarios.*

## Shared Resources

The `shared-resources/` directory may contain common test dependencies used across multiple test scenarios.

## Validation Results

Test results are generated in the `reports/` directory with detailed pass/fail information for each policy-resource combination.