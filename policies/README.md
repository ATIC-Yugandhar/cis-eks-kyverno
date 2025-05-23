# Kyverno Policies

This directory contains all Kyverno policies organized by deployment context and CIS EKS Benchmark sections.

## Structure

### Kubernetes Policies (`kubernetes/`)
Runtime policies that validate live Kubernetes resources in EKS clusters:

- **[control-plane/](kubernetes/control-plane/)** - Section 2: Control Plane Configuration
- **[worker-nodes/](kubernetes/worker-nodes/)** - Section 3: Worker Node Security
- **[rbac/](kubernetes/rbac/)** - Section 4: RBAC and Service Accounts  
- **[pod-security/](kubernetes/pod-security/)** - Section 5: Pod Security Standards

### Terraform Policies (`terraform/`)
Plan-time policies that validate infrastructure configurations before deployment:

- **[cluster-config/](terraform/cluster-config/)** - EKS cluster configuration policies
- **[networking/](terraform/networking/)** - VPC and networking policies
- **[encryption/](terraform/encryption/)** - KMS and encryption policies
- **[monitoring/](terraform/monitoring/)** - Logging and monitoring policies

## Policy Naming Convention

Policies follow the pattern: `cis-[section]-[control]-[short-description].yaml`

Examples:
- `cis-2-1-1-enable-audit-logs.yaml` - CIS control 2.1.1
- `cis-5-4-2-private-endpoint.yaml` - CIS control 5.4.2

## Usage

Each policy directory contains:
- Policy YAML files
- Test cases (see `../../tests/`)
- Documentation explaining the control
- Examples of compliant/non-compliant configurations