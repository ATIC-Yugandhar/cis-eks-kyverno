# Using Kyverno for AWS EKS CIS Benchmark Compliance

The Center for Internet Security (CIS) provides benchmarks for securing various systems, including Kubernetes. The AWS EKS CIS Benchmark offers specific guidance for hardening Amazon Elastic Kubernetes Service (EKS) clusters. Ensuring compliance with these benchmarks is crucial for maintaining a strong security posture.

Kyverno, a policy engine designed for Kubernetes, plays a significant role in automating the enforcement and governance of these security best practices directly within the cluster. It allows administrators to define policies that validate, mutate, or generate Kubernetes resource configurations, helping to meet many CIS requirements.

## The Role of the Kyverno AWS Adapter

While many CIS controls relate directly to Kubernetes resource configurations (like Pod security settings or RBAC rules), some depend on the underlying AWS infrastructure configuration of the EKS cluster itself. This is where the Kyverno AWS Adapter becomes potentially useful.

The Kyverno AWS Adapter extends Kyverno's capabilities by allowing policies to query AWS resource configurations through a Custom Resource Definition (CRD). This enables Kyverno to make policy decisions based on the state of AWS resources associated with the EKS cluster.

For example, although not implemented with specific policies in this repository currently, the adapter *could* be used to create policies that audit or enforce controls related to:
*   **Audit Logging (2.1.1):** Checking if EKS control plane logging is enabled in CloudWatch.
*   **Secret Encryption (5.3.1):** Verifying that Kubernetes secrets encryption using KMS is enabled for the EKS cluster.
*   **Endpoint Access (5.4.1, 5.4.2):** Checking if the EKS control plane endpoint is private or has restricted public access CIDRs.

By bridging the gap between Kubernetes-native resources and AWS configurations, the adapter allows for a more holistic approach to compliance within the Kyverno framework for certain controls.

## EKS CIS Control Summary and Kyverno Support

| CIS Control ID | Description                                                         | Kyverno Support | Test Result | Notes/Links                                                    |
|---------------|----------------------------------------------------------------------|----------------|-------------|----------------------------------------------------------------|
| 2.1.1         | Enable audit logs                                                    | ❌             | fail        | -                                                              |
| 2.1.2         | Ensure audit logs are collected and managed                          | ❌             | fail        | -                                                              |
| 3.1.1         | kubeconfig file permissions set to 644 or more restrictive           | ❌             | fail        | -                                                              |
| 3.1.2         | kubelet kubeconfig file owned by root:root                           | ❌             | fail        | -                                                              |
| 3.1.3         | kubelet config file permissions set to 644 or more restrictive       | ❌             | fail        | -                                                              |
| 3.1.4         | kubelet config file owned by root:root                               | ❌             | fail        | -                                                              |
| 3.2.1         | Anonymous Auth not enabled                                           | ⚠️ Partial     | audit       | manual external audit                                          |
| 3.2.2         | --authorization-mode not set to AlwaysAllow                          | ⚠️ Partial     | audit       | manual external audit                                          |
| 3.2.3         | Client CA file configured                                            | ❌             | fail        | -                                                              |
| 3.2.4         | --read-only-port is disabled                                         | ❌             | fail        | -                                                              |
| 3.2.5         | --streaming-connection-idle-timeout not set to 0                      | ❌             | fail        | -                                                              |
| 3.2.6         | --make-iptables-util-chains set to true                              | ❌             | fail        | -                                                              |
| 3.2.7         | --eventRecordQPS set appropriately or to 0                            | ❌             | fail        | -                                                              |
| 3.2.8         | --rotate-certificates is true or absent                              | ❌             | fail        | -                                                              |
| 3.2.9         | RotateKubeletServerCertificate is true                               | ❌             | fail        | -                                                              |
| 4.1.1         | Use cluster-admin role only when required                             | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.1.2         | Minimize access to secrets                                            | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.1.3         | Minimize wildcard use in roles                                        | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.1.4         | Minimize access to create pods                                        | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.1.5         | Default service accounts should not be used                           | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.1.6         | Mount service account tokens only when necessary                      | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.1.7         | Use Cluster Access Manager API                                        | ❌             | fail        | -                                                              |
| 4.1.8         | Limit Bind, Impersonate, Escalate permissions                         | ⚠️ Partial     | audit       | [external audit](docs/kyverno-limitations.md#rbac-bind-check)    |
| 4.2.1         | Minimize privileged containers                                        | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.2.2         | Minimize host PID namespace sharing                                   | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.2.3         | Minimize host IPC namespace sharing                                   | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.2.4         | Minimize host network namespace sharing                               | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.2.5         | Disallow allowPrivilegeEscalation                                     | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.3.1         | Ensure CNI plugin supports network policies                            | ❌             | fail        | -                                                              |
| 4.3.2         | Ensure all Namespaces have Network Policies                            | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.4.1         | Use secrets as files, not environment variables                        | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 4.4.2         | Use external secret storage                                            | ❌             | fail        | -                                                              |
| 4.5.1         | Use namespaces for resource boundaries                                 | ⚠️ Partial     | audit       | [custom-policy](kyverno-policies/cis/custom/cis-4.5.1-custom.yaml) |
| 4.5.2         | Avoid using the default namespace                                      | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 5.1.1         | Enable image scanning in ECR or third-party                            | ❌             | fail        | -                                                              |
| 5.1.2         | Minimize user access to ECR                                            | ❌             | fail        | -                                                              |
| 5.1.3         | Limit cluster ECR access to read-only                                  | ❌             | fail        | -                                                              |
| 5.1.4         | Restrict use to approved container registries                          | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 5.2.1         | Use dedicated EKS Service Accounts                                     | ⚠️ Partial     | audit       | [custom-policy](kyverno-policies/cis/custom/cis-5.2.1-custom.yaml) |
| 5.3.1         | Encrypt Kubernetes Secrets with KMS CMKs                               | ❌             | fail        | -                                                              |
| 5.4.1         | Restrict control plane endpoint access                                 | ❌             | fail        | -                                                              |
| 5.4.2         | Use private endpoint, disable public access                            | ❌             | fail        | -                                                              |
| 5.4.3         | Deploy private nodes                                                   | ❌             | fail        | -                                                              |
| 5.4.4         | Enable and configure Network Policy                                    | ✅             | pass        | [compliant_policyreport.txt](results/compliant_policyreport.txt) |
| 5.4.5         | Use TLS to encrypt load balancer traffic                               | ❌             | fail        | -                                                              |
| 5.5.1         | Manage users via IAM Authenticator or AWS CLI                          | ❌             | fail        | -                                                              |

**Legend:**
* ✅ **Pass**: Policy passed in automated tests
* ⚠️ **Audit**: Partial coverage or requires manual audit
* ❌ **Fail**: No policy support; requires external process

### Kyverno Policy Structure

The Kyverno policies for CIS benchmarks in this repository are organized under the `kyverno-policies/cis/` directory with the following structure:

*   **`supported/`**: This directory contains Kyverno policies that directly address CIS controls generally enforceable through standard Kubernetes resource validation or mutation. These represent the core, well-supported checks.
*   **`custom/`**: This directory houses custom or experimental Kyverno policies attempting to address more complex CIS controls that might require specific configurations, context, or have limitations. Examples include policies related to `bind`/`impersonate` RBAC checks (4.1.8), requiring specific namespace labels (related to 4.5.1), or checking for IRSA annotations on ServiceAccounts (related to 5.2.1). These policies might be less universally applicable or require careful review in your specific environment.

The automated testing script (`scripts/automated_deploy_test_destroy.sh`) applies policies recursively from the parent `kyverno-policies/cis/` directory, ensuring both supported and custom policies are deployed during testing.

### Coverage and Limitations

It's crucial to understand the scope and limitations when using Kyverno for EKS CIS benchmark compliance:

*   **Kubernetes API Focus:** Kyverno operates primarily by intercepting requests to the Kubernetes API server. It can validate, mutate, or generate Kubernetes resources based on these requests.
*   **Cannot Enforce Host-Level or External Settings:** Kyverno **cannot** directly enforce or audit configurations outside the Kubernetes API's control. This includes:
    *   Host operating system settings or file permissions on worker nodes (e.g., kubeconfig permissions, kubelet file ownership).
    *   API Server or Kubelet command-line flags and configuration files.
    *   External AWS resource configurations (e.g., ECR scanning enablement, KMS key policies, detailed IAM user permissions beyond ServiceAccounts, CloudWatch Log Group configurations).
    *   Infrastructure settings like the EKS control plane endpoint access configuration (public/private CIDRs) or node group settings (private nodes).
    *   External secrets management solutions or processes.

Therefore, while Kyverno is a powerful tool for enforcing many CIS controls related to Kubernetes resource configuration and security posture, achieving full compliance requires supplementing it with other tools and processes. This includes AWS configuration management (e.g., AWS Config, Terraform), node configuration management (e.g., Ansible, userdata scripts), IAM policy reviews, and potentially manual audits for controls outside Kyverno's scope.
For a detailed breakdown of specific CIS controls that fall outside Kyverno's scope and the reasons why, please see the [Kyverno Limitations for EKS CIS Benchmarks](./kyverno-limitations.md) document.

## Terraform Module Structure

The Terraform code used to provision the EKS clusters for testing has been refactored for better modularity and maintainability. The core infrastructure components are now organized into dedicated sub-modules:

*   `networking`: Manages VPC, subnets, and related networking resources.
*   `eks_cluster`: Provisions the core EKS control plane and node groups.
*   `iam`: Defines necessary IAM roles and policies for the cluster and nodes.
*   `security_groups`: Configures security groups for the control plane and worker nodes.
*   `kms`: Sets up KMS keys for encryption (used in the compliant module).

The main modules, `eks_cluster_compliant` and `eks_cluster_non_compliant`, now act as orchestrators, calling these sub-modules with appropriate parameters to create either a security-hardened (compliant) or a less secure (non-compliant) EKS environment for testing purposes. This structure improves code reuse and makes it easier to manage the infrastructure configurations.

## Automated Testing Workflow

This repository includes an automated script, `scripts/automated_deploy_test_destroy.sh`, designed to streamline the process of testing the Kyverno policies against both compliant and non-compliant EKS cluster configurations.

The script aims for full automation, performing the following steps:
1.  **Terraform Backend Setup:** Configures the S3 backend for Terraform state (requires manual setup first, see README).
2.  **Deploy & Test Compliant Cluster:** Provisions a compliant EKS cluster, installs Kyverno, applies policies, and captures results.
3.  **Deploy & Test Non-Compliant Cluster:** Provisions a non-compliant EKS cluster, installs Kyverno, applies policies, and captures results.
4.  **Cleanup:** Destroys both clusters and associated resources.

**Prerequisites and Warnings:**
*   Before running the script, ensure you have met all prerequisites outlined in the main `README.md` (AWS CLI, Terraform, kubectl, Helm, jq installed and configured AWS credentials).
*   **Important:** The script uses `terraform apply -auto-approve` and `terraform destroy -auto-approve`. Run this script in an isolated AWS account or environment designated for testing to avoid unintended resource modifications or deletions in production environments.

**Configuration:**
*   Review and modify configuration variables (AWS region, cluster names, etc.) directly within the `scripts/automated_deploy_test_destroy.sh` script before execution to match your environment.

**Execution:**
1.  Make the script executable: `chmod +x scripts/automated_deploy_test_destroy.sh`
2.  Run the script: `./scripts/automated_deploy_test_destroy.sh`

### Observing Results

The automated script captures the policy reports for both clusters. After the script completes, you will find a timestamped directory under `results/` (e.g., `results/results_YYYYMMDD_HHMMSS/`). This directory contains the output of `kubectl get clusterpolicyreport -A -o wide` and `kubectl get policyreport -A -o wide` for each cluster:

*   `compliant_clusterpolicyreport.txt`
*   `compliant_policyreport.txt`
*   `noncompliant_clusterpolicyreport.txt`
*   `noncompliant_policyreport.txt`

Analyze these files to observe the policy outcomes.

### Observations on Compliant Cluster
Based on the `compliant_clusterpolicyreport.txt` and `compliant_policyreport.txt` files, we observe that the cluster largely adheres to the CIS benchmarks where Kyverno policies apply. Most policies related to security contexts (disallowing privileged pods, host namespaces), RBAC minimization, and network policies show a `pass` status. Some audit-focused policies or custom policies might show `warn` or `fail` for expected configurations (e.g., default service accounts lacking IRSA annotations in user namespaces, roles with specific permissions if present). This confirms the Terraform module provisions a generally compliant EKS configuration according to the defined policies.

[Insert Screenshot of Compliant Cluster Policy Report using tools/MCP]

### Observations on Non-Compliant Cluster
Analyzing the `noncompliant_clusterpolicyreport.txt` and `noncompliant_policyreport.txt` files reveals numerous policy failures, as expected. Policies restricting privileged containers, host namespace sharing (PID, IPC, Network), `allowPrivilegeEscalation`, default service account usage, and potentially missing network policies show `fail` results. This demonstrates Kyverno's ability to detect deviations from the security best practices defined in the CIS policies when applied to a less secure cluster configuration. The custom policies also likely show failures related to missing namespaces or IRSA annotations if applicable resources were present.

[Insert Screenshot of Non-Compliant Cluster Policy Report using tools/MCP]

**Note:** Screenshots are to be captured manually by the user using appropriate tools like `tools/MCP`.
## Conclusion

Kyverno provides a powerful, Kubernetes-native way to enforce a significant portion of the AWS EKS CIS Benchmarks directly within the cluster. By validating resource configurations against defined policies, it helps automate compliance and reduce misconfigurations.

However, achieving full CIS compliance requires a layered security approach. Controls related to AWS infrastructure (like IAM, EKS API settings, logging), node-level configuration, and external tooling (like image scanning or secrets management) must be addressed using appropriate AWS services (Config, IAM, CloudWatch), configuration management tools, and manual processes. Combining Kyverno with these other tools provides a comprehensive strategy for securing your EKS environment according to CIS best practices.