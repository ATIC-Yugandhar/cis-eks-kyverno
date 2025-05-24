# CIS EKS Benchmark to Kyverno Policy Mapping

This document provides a comprehensive mapping of CIS Amazon EKS Benchmark v1.4.0 controls to their corresponding Kyverno policy implementations.

## Mapping Overview

| Status | Symbol | Description |
|--------|--------|-------------|
| Full | ✅ | Complete enforcement through Kyverno |
| Partial | ⚠️ | Partial enforcement with limitations |
| Manual | 📋 | Requires manual verification |
| N/A | ❌ | Not applicable for Kyverno |

## Section 2: Control Plane Configuration

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 2.1.1 | Enable audit logs | `custom-2.1.1.yaml` | Runtime + Terraform | ✅ | Validates EKS audit logging configuration |
| 2.1.2 | Ensure audit log retention | `custom-2.1.2.yaml` | Runtime | ✅ | Checks CloudWatch log retention settings |

### Policy Details: Section 2

#### 2.1.1 - Enable Audit Logs
- **Runtime**: Validates ConfigMap contains audit configuration
- **Terraform**: Checks `cluster_enabled_log_types` includes audit logs
- **Enforcement**: Can block cluster creation without audit logs

#### 2.1.2 - Audit Log Retention
- **Runtime**: Ensures log retention ConfigMap exists
- **Terraform**: Validates CloudWatch log group retention
- **Enforcement**: Prevents inadequate retention periods

## Section 3: Worker Node Security

### 3.1 Worker Node Configuration Files

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 3.1.1 | Kubeconfig file permissions (644 or less) | `custom-3.1.1.yaml` | Runtime | ✅ | Validates file permissions on nodes |
| 3.1.2 | Kubeconfig file ownership (root:root) | `custom-3.1.2.yaml` | Runtime | ✅ | Ensures proper file ownership |
| 3.1.3 | Kubelet config permissions (644 or less) | `custom-3.1.3.yaml` | Runtime | ✅ | Checks kubelet configuration permissions |
| 3.1.4 | Kubelet config ownership (root:root) | `custom-3.1.4.yaml` | Runtime | ✅ | Validates kubelet config ownership |

### 3.2 Kubelet Configuration

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 3.2.1 | Anonymous authentication disabled | `custom-3.2.1.yaml` | Runtime | ✅ | Prevents anonymous access to kubelet |
| 3.2.2 | Authorization mode not AlwaysAllow | `custom-3.2.2.yaml` | Runtime | ✅ | Ensures proper authorization |
| 3.2.3 | Client CA file configured | `custom-3.2.3.yaml` | Runtime | ✅ | Validates client certificate auth |
| 3.2.4 | Read-only port disabled (0) | `custom-3.2.4.yaml` | Runtime | ✅ | Disables insecure read-only port |
| 3.2.5 | Streaming connection idle timeout | `custom-3.2.5.yaml` | Runtime | ✅ | Sets appropriate timeout values |
| 3.2.6 | Protect kernel defaults | `custom-3.2.6.yaml` | Runtime | ✅ | Prevents kernel tuning |
| 3.2.7 | Make event record QPS ≥ 0 | `custom-3.2.7.yaml` | Runtime | ✅ | Ensures event recording |
| 3.2.8 | Enable certificate rotation | `custom-3.2.8.yaml` | Runtime | ✅ | Auto-rotates kubelet certificates |
| 3.2.9 | Enable server certificate rotation | `custom-3.2.9.yaml` | Runtime | ✅ | Rotates server certificates |

## Section 4: RBAC and Service Accounts

### 4.1 RBAC Policies

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 4.1.1 | Restrict cluster-admin binding | `supported-4.1.1.yaml` | Runtime | ✅ | Kyverno built-in policy |
| 4.1.2 | Disallow wildcards in Roles | `supported-4.1.2.yaml` | Runtime | ✅ | Kyverno built-in policy |
| 4.1.3 | Disallow wildcards in ClusterRoles | `supported-4.1.3.yaml` | Runtime | ✅ | Kyverno built-in policy |
| 4.1.4 | Minimize wildcard use in Roles | `supported-4.1.4.yaml` | Runtime | ✅ | Kyverno built-in policy |
| 4.1.5 | Minimize wildcard in ClusterRoles | `supported-4.1.5.yaml` | Runtime | ✅ | Kyverno built-in policy |
| 4.1.6 | Create admin role for control plane | `supported-4.1.6.yaml` | Runtime | ✅ | Validates admin role exists |
| 4.1.7 | Use Cluster Access Manager API | `custom-4.1.7.yaml` | Terraform | ⚠️ | Partial - requires AWS API validation |
| 4.1.8 | Limit bind, impersonate, escalate | `custom-4.1.8.yaml` | Runtime | ✅ | Restricts dangerous permissions |

### 4.2 Pod Security Standards

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 4.2.1 | Enforce Pod Security Standards | `supported-4.2.1.yaml` | Runtime | ✅ | Namespace-level PSS enforcement |
| 4.2.2 | Baseline Pod Security Standard | `supported-4.2.2.yaml` | Runtime | ✅ | Minimum security requirements |
| 4.2.3 | Restricted Pod Security Standard | `supported-4.2.3.yaml` | Runtime | ✅ | Highly restricted pod security |
| 4.2.4 | Consider AppArmor/SELinux/Seccomp | `supported-4.2.4.yaml` | Runtime | ✅ | Additional security profiles |

### 4.3 CNI Plugin

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 4.3.1 | CNI supports Network Policies | `custom-4.3.1.yaml` | Runtime | ⚠️ | Validates NetworkPolicy exists |

### 4.4 Secrets Management

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 4.4.1 | Rotate secrets preferably < 90 days | N/A | N/A | 📋 | Requires external automation |
| 4.4.2 | Use external secret storage | `custom-4.4.2.yaml` | Runtime | ⚠️ | Checks for external secret annotations |

### 4.5 Namespace Separation

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 4.5.1 | Use namespaces for separation | `custom-4.5.1.yaml` | Runtime | ✅ | Prevents default namespace usage |

## Section 5: Pod Security Standards

### 5.1 Image Security

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 5.1.1 | Enable image vulnerability scanning | `custom-5.1.1.yaml` | Runtime + Terraform | ⚠️ | Validates scan annotations |
| 5.1.2 | Minimize ECR user access | `custom-5.1.2.yaml` | Runtime + Terraform | ⚠️ | Checks IAM annotations |
| 5.1.3 | Limit ECR access to read-only | `custom-5.1.3.yaml` | Runtime + Terraform | ⚠️ | Validates read-only access |

### 5.2 Non-root Containers

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 5.2.1 | Prefer non-root containers | Built-in PSS | Runtime | ✅ | Pod Security Standards enforce |

### 5.3 Pod Security Context

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 5.3.1 | Encrypt traffic with KMS | `custom-5.3.1.yaml` | Terraform | ✅ | Validates KMS configuration |

### 5.4 Network Security

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 5.4.1 | Restrict control plane access | `custom-5.4.1.yaml` | Runtime + Terraform | ✅ | Checks endpoint configuration |
| 5.4.2 | Use private endpoint | `custom-5.4.2.yaml` | Runtime + Terraform | ✅ | Validates private endpoint |
| 5.4.3 | Deploy worker nodes privately | `custom-5.4.3.yaml` | Runtime | ⚠️ | Checks node network config |
| 5.4.4 | Run in VPC | Built-in | Terraform | ✅ | Default EKS requirement |
| 5.4.5 | Use TLS for Load Balancers | `custom-5.4.5.yaml` | Runtime | ⚠️ | Validates Service annotations |

### 5.5 Authentication and Authorization

| CIS ID | Control Description | Policy File | Type | Status | Notes |
|--------|-------------------|-------------|------|--------|--------|
| 5.5.1 | Manage users via IAM | `custom-5.5.1.yaml` | Runtime | ⚠️ | Validates IAM integration |

## Policy Implementation Statistics

### By Section
| Section | Total | Full | Partial | Manual |
|---------|--------|------|---------|---------|
| 2.x | 2 | 2 | 0 | 0 |
| 3.x | 13 | 13 | 0 | 0 |
| 4.x | 11 | 7 | 3 | 1 |
| 5.x | 11 | 5 | 6 | 0 |
| **Total** | **37** | **27 (73%)** | **9 (24%)** | **1 (3%)** |

### By Type
| Type | Count | Percentage |
|------|--------|------------|
| Runtime Only | 28 | 76% |
| Terraform Only | 3 | 8% |
| Both | 6 | 16% |

## Usage Guide

### Finding Policies

1. **By CIS ID**: Look up the control number in the tables above
2. **By Category**: Navigate to the appropriate section
3. **By File**: Check `policies/kubernetes/` or `policies/terraform/`

### Understanding Status

- **✅ Full**: Policy completely enforces the control
- **⚠️ Partial**: Policy provides some enforcement, manual verification recommended
- **📋 Manual**: Control requires manual processes or external tools
- **❌ N/A**: Control cannot be enforced via Kyverno

### Policy Naming Convention

```
custom-{section}.{subsection}.{control}.yaml
```

Example: `custom-5.1.1.yaml` = Section 5, Subsection 1, Control 1

### Built-in vs Custom Policies

- **Supported**: Kyverno community policies (`supported-*.yaml`)
- **Custom**: Organization-specific implementations (`custom-*.yaml`)

## Implementation Notes

### Runtime Policies
- Applied to live Kubernetes resources
- Use admission webhooks for enforcement
- Generate PolicyReports for compliance tracking

### Terraform Policies
- Validate infrastructure before deployment
- Use JSON validation against Terraform plans
- Require `KYVERNO_EXPERIMENTAL=true` flag

### Dual Enforcement
Some controls benefit from both approaches:
- Plan-time: Catch misconfigurations early
- Runtime: Ensure ongoing compliance

## Next Steps

1. Review individual [policy documentation](kubernetes-policies.md)
2. Understand [policy limitations](limitations.md)
3. Implement policies using the [getting started guide](../getting-started/)
4. Monitor compliance with [reporting tools](../operations/reporting.md)