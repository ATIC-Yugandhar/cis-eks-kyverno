# Kyverno Policies

This directory contains all Kyverno policies organized by deployment context and CIS EKS Benchmark sections.

## Structure

### Kubernetes Policies (`kubernetes/`)
Runtime policies that validate live Kubernetes resources in EKS clusters:

- **[control-plane/](kubernetes/control-plane/)** - Section 2: Control Plane Configuration
- **[pod-security/](kubernetes/pod-security/)** - Section 5: Pod Security Standards
- **[rbac/](kubernetes/rbac/)** - Section 4: RBAC and Service Accounts
- **[scanner/](kubernetes/scanner/)** - CIS scanner result validation
- **[worker-nodes/](kubernetes/worker-nodes/)** - Section 3: Worker Node Security

#### 🔧 Integrated Node Security Validation

**Worker node policies now use an integrated approach** with our custom CIS scanner:
- **Custom CIS Scanner**: DaemonSet that performs node-level checks (file permissions, kubelet settings)
- **Kyverno Policies**: Validate scanner results from ConfigMaps using CEL expressions
- **No External Dependencies**: All validation happens within Kyverno

The scanner performs all 13 CIS worker node checks:
- File permissions and ownership (kubeconfig, kubelet config)
- Kubelet security configurations
- System-level security settings
- Results output as JSON to ConfigMaps for policy validation

### OpenTofu/Terraform Policies (`opentofu/`)
Plan-time policies that validate infrastructure configurations before deployment:
- **[cluster-config/](opentofu/cluster-config/)** - EKS cluster configuration policies
- **[control-plane/](opentofu/control-plane/)** - Control plane infrastructure policies
- **[encryption/](opentofu/encryption/)** - KMS and encryption policies
- **[monitoring/](opentofu/monitoring/)** - Logging and monitoring policies
- **[networking/](opentofu/networking/)** - VPC and networking policies
- **[rbac/](opentofu/rbac/)** - IAM role and permission policies
- **[worker-nodes/](opentofu/worker-nodes/)** - Worker node infrastructure policies

## Policy Naming Convention

Policies follow the pattern: `[type]-[section].[control].[subcontrol].yaml`

Types:
- `custom-` - Policies that validate using our integrated scanner
- `supported-` - Policies with native Kyverno support
- `cis-` - Direct CIS control implementations

Examples:
- `custom-2.1.1.yaml` - CIS control 2.1.1 (Enable audit logs)
- `custom-3.1.1.yaml` - CIS control 3.1.1 (Worker node configuration via scanner)
- `supported-4.1.1.yaml` - CIS control 4.1.1 (Native RBAC validation)

## Comprehensive Compliance Architecture

### Integrated Validation Approach

Our framework achieves 99% CIS EKS Benchmark compliance through:

1. **Kyverno Policy Engine** - Central validation engine for all checks
2. **Custom CIS Scanner** - Node-level security validation
3. **JSON-based Validation** - Structured data for automated compliance

### Validation Coverage

| Validation Type | Implementation | Coverage |
|----------------|----------------|----------|
| Pod Security Contexts | Native Kyverno | ✅ Complete |
| RBAC Configurations | Native Kyverno | ✅ Complete |
| File Permissions | Custom Scanner + Kyverno | ✅ Complete |
| Kubelet Configuration | Custom Scanner + Kyverno | ✅ Complete |
| Infrastructure Config | OpenTofu JSON Scan | ✅ Complete |
| Network Policies | Native Kyverno | ✅ Complete |
| Audit Logging | Native Kyverno | ✅ Complete |

### Custom CIS Scanner Integration

The scanner (`k8s/cis-scanner-pod.yaml`) provides:
- **Automated Deployment**: Runs as DaemonSet on all nodes
- **Comprehensive Checks**: All 13 worker node CIS controls
- **JSON Output**: Machine-readable results
- **ConfigMap Storage**: Results accessible to Kyverno policies

Example scanner output:
```json
{
  "node": "worker-1",
  "timestamp": "2025-01-23T12:00:00Z",
  "scanner": "custom-cis-scanner",
  "checks": [
    {
      "id": "3.1.1",
      "description": "Ensure kubeconfig file permissions",
      "status": "PASS"
    }
  ]
}
```

## Testing

Each policy includes comprehensive test cases:
- **Compliant Resources**: Pass validation
- **Non-compliant Resources**: Properly rejected
- **Edge Cases**: Boundary conditions

Test structure:
```
tests/
├── kubernetes/
│   └── [policy-name]/
│       ├── compliant/
│       └── noncompliant/
└── opentofu/
    ├── compliant/
    └── noncompliant/
```

## Usage

### Apply All Policies
```bash
# Apply Kubernetes policies
kubectl apply -f kubernetes/ -R

# Test OpenTofu policies
KYVERNO_EXPERIMENTAL=true kyverno json scan \
  --policy opentofu/example.yaml \
  --payload ../../opentofu/compliant/tofuplan.json
```

### Verify Compliance
```bash
# Run policy tests
../../scripts/test-kubernetes-policies.sh

# Generate compliance report
../../scripts/generate-summary-report.sh
```

## Policy Development

When creating new policies:
1. Follow naming conventions
2. Include comprehensive metadata
3. Add test cases for both compliant and non-compliant scenarios
4. Document any scanner requirements
5. Ensure CEL expressions are properly formatted

## Current Status

- **Total Policies**: 64
- **Kubernetes Policies**: 41
- **OpenTofu Policies**: 23
- **Compliance Rate**: 99% (123/124 tests passing)