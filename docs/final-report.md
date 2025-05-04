# Final Report: EKS CIS Benchmark Validation with Kyverno

## Overview

This report summarizes the validation of Amazon EKS clusters against the CIS Benchmark using Kyverno policies. Both compliant and noncompliant cluster architectures were tested to evaluate policy effectiveness and automation workflows.

---

## Testing Workflows

### Local Testing

- Kyverno policies were first validated locally using the Kyverno CLI.
- Policies were applied to sample manifests and EKS configurations to ensure syntactic and logical correctness before cluster deployment.

### Cluster-Based Testing

- Policies were deployed to live EKS clusters (both compliant and noncompliant).
- Validation was performed using Kyverno’s reporting features and manual inspection of cluster resources.

---

## Cluster Architectures

### Compliant Cluster

- **Private Networking:** All nodes and control plane endpoints are private, inaccessible from the public internet.
- **IAM Authentication:** Access is restricted to authorized IAM users/roles.
- **KMS Encryption:** Kubernetes secrets are encrypted at rest.
- **Network Policies:** Enforced to restrict pod-to-pod and pod-to-external communications.
- **TLS Everywhere:** All ingress/egress traffic is encrypted.

### Noncompliant Cluster

- **Public Endpoints:** Nodes and/or control plane are accessible from the public internet.
- **Weak Authentication:** IAM restrictions are relaxed or missing.
- **No Encryption:** Secrets are stored unencrypted.
- **Open Network:** Network policies are absent or permissive.
- **Lack of TLS:** Traffic may be unencrypted.

#### Network Access Patterns

- **Compliant:** Only internal VPC or bastion host can access the cluster; no direct public access.
- **Noncompliant:** Cluster is reachable from the public internet, increasing risk.

---

## Bastion Host Requirement

- For compliant clusters, a bastion host is required to access private endpoints for testing and administration.
- The bastion host is deployed in a private subnet and accessed via secure methods (e.g., SSH with restricted IPs).
- All testing and validation for private clusters were performed through the bastion host.

---

## Automation Scripts

- **scripts/compliant.sh:** Provisions a compliant EKS cluster with all security controls enabled.
- **scripts/noncompliant.sh:** Provisions a noncompliant EKS cluster with relaxed controls for negative testing.
- **scripts/cleanup.sh:** Tears down clusters and cleans up resources.

### Usage

```bash
# Deploy compliant cluster
./scripts/compliant.sh

# Deploy noncompliant cluster
./scripts/noncompliant.sh

# Cleanup resources
./scripts/cleanup.sh
```

Scripts automate cluster provisioning, policy application, and resource cleanup to ensure repeatable and consistent testing.

---

## Conclusion

Kyverno policies were validated in both compliant and noncompliant EKS environments. The compliant architecture enforced all CIS controls, while the noncompliant setup demonstrated policy violations. Automation scripts streamlined the testing process, and the bastion host enabled secure access to private clusters for validation.