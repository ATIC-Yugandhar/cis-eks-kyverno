# Kyverno Policies

This directory contains all Kyverno policies organized by deployment context and CIS EKS Benchmark sections.

## Structure

### Kubernetes Policies (`kubernetes/`)
Runtime policies that validate live Kubernetes resources in EKS clusters:

- **[control-plane/](kubernetes/control-plane/)** - Section 2: Control Plane Configuration
- **[worker-nodes/](kubernetes/worker-nodes/)** - Section 3: Worker Node Security (⚠️ **Requires kube-bench integration**)
- **[rbac/](kubernetes/rbac/)** - Section 4: RBAC and Service Accounts
- **[pod-security/](kubernetes/pod-security/)** - Section 5: Pod Security Standards

#### ⚠️ Important: Worker Node Policy Limitations

**Worker node policies have inherent limitations** because most CIS worker node controls require direct access to:
- Kubelet configuration files on worker nodes
- File permissions and ownership on the node filesystem
- System-level configurations that Kyverno cannot access

**Hybrid Validation Approach Required:**
- **Kube-bench**: Validates actual node-level configurations (file permissions, kubelet settings, etc.)
- **Kyverno**: Validates Pod security contexts and Kubernetes-level controls

All worker node policies include annotations indicating their kube-bench dependency and validation scope limitations.

### OpenTofu/Terraform Policies (`opentofu/`)
Plan-time policies that validate infrastructure configurations before deployment (compatible with both OpenTofu and Terraform):
- **[cluster-config/](opentofu/cluster-config/)** - EKS cluster configuration policies
- **[networking/](opentofu/networking/)** - VPC and networking policies
- **[encryption/](opentofu/encryption/)** - KMS and encryption policies
- **[monitoring/](opentofu/monitoring/)** - Logging and monitoring policies

## Policy Naming Convention

Policies follow the pattern: `custom-[section].[control].[subcontrol].yaml`

Examples:
- `custom-2.1.1.yaml` - CIS control 2.1.1 (Enable audit logs)
- `custom-5.4.2.yaml` - CIS control 5.4.2 (Private endpoint access)
- `custom-3.1.1.yaml` - CIS control 3.1.1 (Worker node configuration)

## Comprehensive CIS Compliance Strategy

### Multi-Tool Validation Approach

Achieving comprehensive CIS EKS Benchmark compliance requires multiple validation tools working together:

1. **Kyverno** - Validates Kubernetes resources and API-level configurations
2. **Kube-bench** - Validates node-level configurations and file system checks
3. **OpenTofu** - Validates infrastructure configuration at plan-time

### Tool Capabilities and Boundaries

| Validation Type | Kyverno | Kube-bench | OpenTofu |
|----------------|---------|------------|----------|
| Pod Security Contexts | ✅ | ❌ | ❌ |
| RBAC Configurations | ✅ | ❌ | ❌ |
| File Permissions | ❌ | ✅ | ❌ |
| Kubelet Configuration | ❌ | ✅ | ❌ |
| Infrastructure Config | ❌ | ❌ | ✅ |
| Network Policies | ✅ | ❌ | ✅ |

### Worker Node Controls Explained

Worker node policies in this repository acknowledge these limitations by:
- Providing clear annotations about kube-bench requirements
- Focusing on what Kyverno CAN validate (Pod security contexts, resource limits, etc.)
- Including detailed descriptions of the hybrid validation approach
- Maintaining value for complementary Kubernetes-level checks

## Usage

Each policy directory contains:
- Policy YAML files with clear limitation documentation
- Test cases (see `../../tests/`)
- Documentation explaining the control and validation boundaries
- Examples of compliant/non-compliant configurations