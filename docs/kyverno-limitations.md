# Kyverno Limitations for EKS CIS Benchmarks

While Kyverno is a powerful policy engine for managing Kubernetes resources, its architecture imposes certain limitations, preventing it from covering all EKS CIS benchmark controls. This document outlines specific controls that require alternative tools or approaches due to these limitations.

## Host-Level Configuration/Filesystem Access

**Limitation:** Kyverno operates as pods within the Kubernetes cluster and lacks direct access to the underlying host node's filesystem or processes. Therefore, it cannot verify file permissions, ownership, or other host-level configurations required by some CIS benchmarks.

**Affected Controls:**
*   3.1.1
*   3.1.2
*   3.1.3
*   3.1.4

## API Server / Kubelet Startup Flags

**Limitation:** Kyverno policies cannot inspect the command-line arguments or flags used to start the Kubernetes API server (managed by AWS EKS) or the kubelet processes running on worker nodes. Verifying these configurations requires checking the cluster provisioning methods (e.g., Infrastructure as Code, AWS Console) or using external audit tools that can inspect process arguments on the nodes.

**Affected Controls:**
*   3.2.1
*   3.2.2
*   3.2.3
*   3.2.4
*   3.2.5
*   3.2.6
*   3.2.7
*   3.2.8
*   3.2.9

## External AWS Service Configuration / Integration

**Limitation:** Kyverno's scope is limited to the Kubernetes API. It cannot directly configure, audit, or verify the status of external AWS services or EKS cluster-level settings managed through the AWS API. Compliance for these controls must be managed using AWS-native tools (Console, CLI, SDK), Infrastructure as Code (like Terraform), or AWS auditing services (e.g., AWS Config, Security Hub).

**Affected Controls:**
*   2.1.1 (CloudWatch Audit Logs)
*   2.1.2 (CloudWatch Audit Logs)
*   4.1.7 (Cluster Access Manager API - assuming external)
*   4.4.2 (External Secret Storage - verification of external store)
*   5.1.1 (ECR Scanning/Permissions)
*   5.1.2 (ECR Scanning/Permissions)
*   5.1.3 (ECR Scanning/Permissions)
*   5.3.1 (KMS Encryption for Secrets)
*   5.4.1 (Control Plane Security Group/Firewall)
*   5.4.5 (ELB TLS Configuration)
*   5.5.1 (IAM Authenticator/User Management)

## Infrastructure Configuration (Managed by IaC)

**Limitation:** Settings related to the underlying AWS infrastructure, such as using private EKS endpoints or deploying worker nodes into private subnets, are defined during cluster provisioning. These are typically managed via Infrastructure as Code (IaC) tools like the Terraform modules used in this project. Kyverno cannot enforce the creation or configuration of this external infrastructure.

**Affected Controls:**
*   5.4.2
*   5.4.3

## CNI Plugin Capabilities

**Limitation:** Verifying specific capabilities or configurations of the installed Container Network Interface (CNI) plugin, such as its support for Kubernetes Network Policies, is highly dependent on the specific CNI implementation. Reliably checking these details via Kyverno policies is often impractical or impossible.

**Affected Controls:**
*   4.3.1

## Conclusion

Achieving comprehensive EKS CIS compliance requires a multi-layered security strategy. While Kyverno is essential for enforcing policies on Kubernetes resources within the cluster, it must be complemented by Infrastructure as Code (Terraform) for provisioning, host-based security tools for node-level checks, and AWS-native services for configuring and auditing cloud resources and cluster settings.