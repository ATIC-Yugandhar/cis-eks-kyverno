# OpenTofu CIS EKS Compliance Testing

This directory contains OpenTofu configurations for testing CIS EKS Benchmark compliance using Kyverno policies at plan-time.

## Overview

The OpenTofu configurations demonstrate compliant vs. non-compliant AWS EKS infrastructure patterns for CIS security controls validation. These configurations enable automated security compliance testing during the infrastructure planning phase.

## Directory Structure

```
opentofu/
├── README.md                    # This file
├── compliant/                   # CIS-compliant EKS configuration
│   ├── main.tf                 # Main infrastructure resources
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── tofuplan.json          # Generated plan file (JSON)
│   └── tofuplan.binary        # Generated plan file (binary)
└── noncompliant/               # Non-compliant EKS configuration
    ├── main.tf                 # Main infrastructure resources
    ├── variables.tf            # Input variables
    ├── tofuplan.json          # Generated plan file (JSON)
    └── tofuplan.binary        # Generated plan file (binary)
```

## Configuration Profiles

### Compliant Configuration (`compliant/`)

**Purpose**: Demonstrates CIS EKS Benchmark compliant infrastructure configuration that adheres to security best practices.

**Security Features**:
- ✅ Private EKS cluster endpoints (endpoint_private_access: true, endpoint_public_access: false)
- ✅ Comprehensive audit logging (api, audit, authenticator, controllerManager, scheduler)
- ✅ KMS encryption for EKS secrets with key rotation enabled
- ✅ ECR repositories with image scanning enabled
- ✅ Private subnets for worker nodes with proper tagging
- ✅ Secrets Manager with KMS encryption
- ✅ Security groups with restrictive ingress rules
- ✅ Proper resource tagging for compliance tracking
- ✅ EKS add-ons for enhanced security (VPC CNI)
- ✅ Network policies for pod-to-pod communication control

**CIS Controls Implemented**:
- **2.1.1-2.1.3**: Audit logging configuration and retention
- **4.3.1**: Network policy support via VPC CNI add-on
- **5.1.1**: ECR image scanning and security group controls
- **5.3.1-5.3.2**: Encryption at rest for secrets and EKS resources
- **5.4.2-5.4.4**: Private networking and network policies
- **5.5.1**: Resource management and tagging requirements

### Non-compliant Configuration (`noncompliant/`)

**Purpose**: Demonstrates security anti-patterns that violate CIS EKS Benchmark controls for testing policy detection capabilities.

**Security Violations**:
- ❌ Public EKS cluster endpoints (endpoint_public_access: true)
- ❌ No audit logging configured (enabled_cluster_log_types: [])
- ❌ Unencrypted secrets and repositories (no KMS configuration)
- ❌ Public subnets for worker nodes
- ❌ Missing required resource tags
- ❌ Overly permissive security groups (SSH from 0.0.0.0/0)
- ❌ Overprivileged IAM roles with wildcard permissions
- ❌ No image scanning for container repositories

**CIS Controls Violated**:
- **2.1.1-2.1.3**: No audit logging or retention policies
- **4.1.1-4.1.4**: Overprivileged IAM roles and policies
- **5.1.1**: Disabled image scanning, permissive security groups
- **5.3.1-5.3.2**: No encryption for secrets or EKS resources
- **5.4.2-5.4.3**: Public endpoints and worker node placement
- **5.5.1**: Missing resource tags and quotas

## Policy Validation Results

### Performance Summary

| Metric | Compliant Configuration | Non-compliant Configuration |
|--------|------------------------|----------------------------|
| **Total Policies** | 23 | 23 |
| **Success Rate** | **91%** (21/23 policies) | **52%** detection rate |
| **Coverage** | Infrastructure security controls | Security violation detection |

### Policy Categories

#### Fully Validated Controls (20/23 policies)

**Control Plane Security**:
- ✅ Audit logging configuration (CIS 2.1.1-2.1.3)
- ✅ Authorization mode validation (CIS 2.2.1)

**Encryption & Data Protection**:
- ✅ KMS encryption for secrets (CIS 5.3.1-5.3.2)
- ✅ EKS cluster encryption configuration

**Container & Image Security**:
- ✅ ECR image scanning requirements (CIS 5.1.1)
- ✅ ECR access minimization (CIS 5.1.2)

**Network Security**:
- ✅ VPC CNI and network policy support (CIS 4.3.1)
- ✅ Private endpoint configuration (CIS 5.4.2)
- ✅ Private worker node placement (CIS 5.4.3)
- ✅ Network policy implementation (CIS 5.4.4)
- ✅ Security group rule validation (CIS 5.1.1-5.1.2)

**Worker Node Security**:
- ✅ Worker node security configuration (CIS 3.1.1)
- ✅ AMI type and subnet placement validation

**Resource Management**:
- ✅ Resource tagging requirements
- ✅ IAM authenticator configuration (CIS 5.5.1)
- ✅ Resource quota validation (CIS 5.5.1)

**Access Control (Partial)**:
- ✅ Basic IAM role validation (CIS 4.1.1, 4.1.2, 4.1.4)
- ⚠️ Complex IAM policy analysis (CIS 4.1.3, 4.1.8)

#### Plan-time Validation Scope

**Strengths**:
- Infrastructure resource configuration validation
- Resource relationship and dependency verification
- Security setting compliance checks
- Encryption and networking control validation

**Limitations**:
- Complex IAM policy document analysis requires runtime validation
- Kubernetes RBAC resources not present in infrastructure plans
- Dynamic security configurations need cluster-level validation
- Advanced privilege escalation scenarios require behavioral analysis

## Implementation Details

### CIS Benchmark Mapping

| CIS Control | Policy Name | Validation Scope | Implementation |
|-------------|-------------|------------------|----------------|
| 2.1.1 | enable-audit-logs | Control Plane | EKS audit log types |
| 2.1.2 | audit-log-destinations | Control Plane | CloudWatch log groups |
| 2.1.3 | audit-log-retention | Control Plane | Log retention policies |
| 3.1.1 | worker-node-security | Worker Nodes | AMI types, subnet placement |
| 4.1.1-4.1.4 | minimize-* permissions | IAM | Role and policy validation |
| 5.1.1 | image-scanning | Monitoring | ECR scanning configuration |
| 5.3.1-5.3.2 | encrypt-secrets-kms | Encryption | KMS key usage |
| 5.4.2-5.4.4 | private-* networking | Networking | VPC and network policies |
| 5.5.1 | resource-quotas | Resource Mgmt | Tagging and quotas |

### Resource Architecture

**Compliant Configuration Resources**:
- 1 VPC with DNS support and hostnames
- 3 private subnets across availability zones
- 1 EKS cluster with private endpoints
- 1 EKS node group with secure AMI
- 4 IAM roles with least-privilege policies
- 1 KMS key with rotation enabled
- 1 CloudWatch log group for audit logs
- 1 ECR repository with scanning
- 1 Secrets Manager secret with encryption
- 1 EKS add-on for VPC CNI
- 1 Kubernetes network policy

**Non-compliant Configuration Resources**:
- 1 VPC without proper DNS configuration
- 3 public subnets (security violation)
- 1 EKS cluster with public endpoints
- 1 EKS node group in public subnets
- 3 IAM roles including overprivileged role
- 1 overprivileged IAM policy with wildcards
- 1 unencrypted ECR repository
- 1 unencrypted Secrets Manager secret
- Security groups with permissive rules

## Usage Instructions

### Testing Configurations

```bash
# Test both configurations against all policies
./scripts/test-opentofu-policies.sh

# Test specific configuration
cd opentofu/compliant
tofu plan -out=tofuplan.binary
tofu show -json tofuplan.binary > tofuplan.json
```

### Generating New Plans

```bash
# Update compliant configuration
cd compliant/
tofu plan -out=tofuplan.binary
tofu show -json tofuplan.binary > tofuplan.json

# Update non-compliant configuration  
cd ../noncompliant/
tofu plan -out=tofuplan.binary
tofu show -json tofuplan.binary > tofuplan.json
```

### Policy Validation

```bash
# Run specific policy test
kyverno-json scan --policy ../../policies/opentofu/require-tags.yaml --payload tofuplan.json

# Validate encryption policies
kyverno-json scan --policy ../../policies/opentofu/encryption/ --payload tofuplan.json
```

## Development Guidelines

### Configuration Standards

**Compliant Configuration Requirements**:
- All resources must include proper tags (`Environment`, `Owner`)
- Security configurations must follow CIS recommendations
- Encryption must be enabled for all data stores
- Network access must be minimized (private subnets, private endpoints)
- IAM permissions must follow least-privilege principle

**Non-compliant Configuration Requirements**:
- Must violate specific CIS controls for testing
- Should include common security misconfigurations
- Must maintain infrastructure functionality
- Should represent realistic security violations

### Policy Development

**Best Practices**:
- Focus on infrastructure resource attributes
- Use simple presence/absence validation logic
- Validate resource relationships and dependencies
- Include clear violation messages
- Test against both configuration types

**Testing Requirements**:
- Policies must pass on compliant configurations
- Policies must fail on non-compliant configurations
- Validation logic must be deterministic
- Performance must be acceptable for CI/CD integration

## Integration Patterns

### CI/CD Pipeline Integration

```yaml
# Example GitHub Actions workflow
- name: Validate OpenTofu Compliance
  run: |
    cd opentofu/compliant
    tofu plan -out=plan.binary
    tofu show -json plan.binary > plan.json
    ../scripts/test-opentofu-policies.sh
```

### Multi-layer Validation

**Plan-time (OpenTofu)**: Infrastructure configuration validation
**Runtime (Kubernetes)**: RBAC and pod security validation  
**Continuous (Monitoring)**: Behavioral and configuration drift detection

### Compliance Reporting

- Generate compliance reports with policy results
- Track compliance metrics over time
- Integrate with security dashboards
- Export results to compliance management systems

## Related Documentation

- [CIS Amazon EKS Benchmark v1.7.0](../docs/CIS_Amazon_Elastic_Kubernetes_Service_(EKS)_Benchmark_v1.7.0_PDF.pdf)
- [Kyverno JSON Documentation](https://kyverno.github.io/kyverno-json/)
- [Policy Directory](../policies/opentofu/)
- [Testing Scripts](../scripts/)
- [Project README](../README.md)

## Support and Contribution

For questions, issues, or contributions:
1. Review existing policies and configurations
2. Test changes against both configuration types
3. Update documentation with any modifications
4. Ensure compliance metrics are maintained or improved

This framework provides a foundation for infrastructure security compliance validation and can be extended to support additional CIS controls and security requirements.