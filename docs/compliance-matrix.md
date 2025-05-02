# CIS EKS Benchmark Compliance Matrix

This document maps the CIS EKS Benchmark controls to Kyverno policies implemented in this repository.

## Coverage Summary

| Coverage Type | Count |
|--------------|-------|
| ✅ Kubernetes Policy | 16 |
| 🔶 Custom Policy | 3 |
| 🔷 Terraform Policy | 23 |
| ⚠️ Partial/Audit | 3 |
| ❌ Not Supported | 0 |
| **Total** | **45** |

## Detailed Control Matrix

| CIS ID | Description                                                         | Kyverno Support   | Implementation Method | Notes/Links |
|--------|---------------------------------------------------------------------|-------------------|----------------------|-------------|
| 2.1.1  | Enable audit logs                                                   | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-2.1.1-enable-audit-logs.yaml) |
| 2.1.2  | Ensure audit logs are collected and managed                         | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-2.1.2-ensure-audit-logs-managed.yaml) |
| 3.1.1  | kubeconfig file permissions set to 644 or more restrictive          | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.1.1-kubeconfig-permissions.yaml) |
| 3.1.2  | kubelet kubeconfig file owned by root:root                          | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.1.2-kubelet-kubeconfig-ownership.yaml) |
| 3.1.3  | kubelet config file permissions set to 644 or more restrictive      | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.1.3-kubelet-config-permissions.yaml) |
| 3.1.4  | kubelet config file owned by root:root                              | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.1.4-kubelet-config-ownership.yaml) |
| 3.2.1  | Anonymous Auth not enabled                                          | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.2.1-disable-anonymous-auth.yaml) |
| 3.2.2  | --authorization-mode not set to AlwaysAllow                          | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-3.2.2.yaml) |
| 3.2.3  | Client CA file configured                                           | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.2.3-client-ca-file.yaml) |
| 3.2.4  | --read-only-port is disabled                                        | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.2.4-read-only-port-disabled.yaml) |
| 3.2.5  | --streaming-connection-idle-timeout not set to 0                     | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.2.5-streaming-connection-timeout.yaml) |
| 3.2.6  | --make-iptables-util-chains set to true                             | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.2.6-iptables-util-chains.yaml) |
| 3.2.7  | --eventRecordQPS set appropriately or to 0                           | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.2.7-event-record-qps.yaml) |
| 3.2.8  | --rotate-certificates is true or absent                             | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.2.8-rotate-certificates.yaml) |
| 3.2.9  | RotateKubeletServerCertificate is true                              | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-3.2.9-rotate-kubelet-server-certificate.yaml) |
| 4.1.1  | Use cluster-admin role only when required                           | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.1.1.yaml) |
| 4.1.2  | Minimize access to secrets                                          | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.1.2.yaml) |
| 4.1.3  | Minimize wildcard use in roles                                      | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.1.3.yaml) |
| 4.1.4  | Minimize access to create pods                                      | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.1.4.yaml) |
| 4.1.5  | Default service accounts should not be used                         | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.1.5.yaml) |
| 4.1.6  | Mount service account tokens only when necessary                    | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.1.6.yaml) |
| 4.1.7  | Use Cluster Access Manager API                                      | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-4.1.7-cluster-access-manager.yaml) |
| 4.1.8  | Limit Bind, Impersonate, Escalate permissions                       | ⚠️ Partial        | Audit               | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.1.8.yaml) |
| 4.2.1  | Minimize privileged containers                                      | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.2.1.yaml) |
| 4.2.2  | Minimize host PID namespace sharing                                 | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.2.2.yaml) |
| 4.2.3  | Minimize host IPC namespace sharing                                 | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.2.3.yaml) |
| 4.2.4  | Minimize host network namespace sharing                             | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.2.4.yaml) |
| 4.2.5  | Disallow allowPrivilegeEscalation                                   | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.2.5.yaml) |
| 4.3.1  | Ensure CNI plugin supports network policies                         | 🔷 Terraform      | Infrastructure Check | Via Amazon VPC CNI Plugin |
| 4.3.2  | Ensure all Namespaces have Network Policies                         | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.3.2.yaml) |
| 4.4.1  | Use secrets as files, not environment variables                     | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.4.1.yaml) |
| 4.4.2  | Use external secret storage                                         | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-4.4.2-external-secret-storage.yaml) |
| 4.5.1  | Use namespaces for resource boundaries                              | 🔶 Custom         | Custom Policy        | [Custom Policy](../kyverno-policies/cis/custom/cis-4.5.1-custom.yaml) |
| 4.5.2  | Avoid using the default namespace                                   | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-4.5.2.yaml) |
| 5.1.1  | Enable image scanning in ECR or third-party                         | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-5.1.1-enable-image-scanning.yaml) |
| 5.1.2  | Minimize user access to ECR                                         | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-5.1.2-minimize-ecr-access.yaml) |
| 5.1.3  | Limit cluster ECR access to read-only                               | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-5.1.3-readonly-ecr-access.yaml) |
| 5.1.4  | Restrict use to approved container registries                       | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-5.1.4.yaml) |
| 5.2.1  | Use dedicated EKS Service Accounts                                  | 🔶 Custom         | Custom Policy        | [Custom Policy](../kyverno-policies/cis/custom/cis-5.2.1-custom.yaml) |
| 5.3.1  | Encrypt Kubernetes Secrets with KMS CMKs                            | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-5.3.1-encrypt-secrets-with-kms.yaml) |
| 5.4.1  | Restrict control plane endpoint access                              | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-5.4.1-restrict-control-plane-access.yaml) |
| 5.4.2  | Use private endpoint, disable public access                         | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-5.4.2-private-endpoint.yaml) |
| 5.4.3  | Deploy private nodes                                                | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-5.4.3-private-nodes.yaml) |
| 5.4.4  | Enable and configure Network Policy                                 | ✅ Kubernetes     | Cluster Validation   | [Kubernetes Policy](../kyverno-policies/cis/supported/cis-5.4.4.yaml) |
| 5.4.5  | Use TLS to encrypt load balancer traffic                            | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-5.4.5-tls-load-balancer.yaml) |
| 5.5.1  | Manage users via IAM Authenticator or AWS CLI                       | 🔷 Terraform      | Infrastructure Check | [Terraform Policy](../kyverno-policies/terraform/cis-5.5.1-iam-authenticator.yaml) |

## Legend

- ✅ **Kubernetes Policy**: Implemented as a Kyverno policy for validating Kubernetes resources
- 🔶 **Custom Policy**: Custom Kyverno policy implementation 
- 🔷 **Terraform Policy**: Implemented as a Kyverno policy for validating Terraform plans
- ⚠️ **Partial/Audit**: Partial coverage or requires manual audit
- ❌ **Not Supported**: No policy support; requires external process