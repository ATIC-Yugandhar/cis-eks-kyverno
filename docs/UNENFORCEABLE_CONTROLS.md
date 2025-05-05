# Unenforceable or Partially Enforceable CIS EKS Controls with Kyverno

This document lists all CIS EKS Benchmark controls that cannot be fully enforced by Kyverno policies, along with explanations and notes on test automation.

| CIS ID  | Description                                              | Reason Not Enforceable by Kyverno                |
|---------|----------------------------------------------------------|--------------------------------------------------|
| 4.1.7   | Use Cluster Access Manager API                           | Requires AWS IAM/AWS API, not Kubernetes objects |
| 4.3.1   | Ensure CNI plugin supports network policies              | CNI plugin configuration is outside Kyverno scope|
| 4.4.2   | Use external secret storage                              | External secret storage is not a K8s resource    |
| 5.1.1   | Enable image scanning in ECR or third-party              | ECR/3rd-party scanning is outside K8s API        |
| 5.1.2   | Minimize user access to ECR                              | ECR is an AWS resource, not a K8s resource       |
| 5.1.3   | Limit cluster ECR access to read-only                    | ECR is an AWS resource, not a K8s resource       |
| 5.4.1   | Restrict control plane endpoint access                   | Control plane endpoint is managed by AWS         |
| 5.4.3   | Deploy private nodes                                     | Node deployment is managed by AWS                |
| 5.4.5   | Use TLS to encrypt load balancer traffic                 | Load balancer TLS is managed by AWS              |
| 5.5.1   | Manage users via IAM Authenticator or AWS CLI            | IAM Authenticator is outside K8s API             |

**Note:** Some controls are only partially enforceable (e.g., those requiring audit or external validation). For these, see the corresponding `custom-<cis-id>.yaml` policy with `audit` mode and annotations. 

---

**Additional Limitation:**
For controls like 2.1.1 and 2.1.2 (audit logging), Kyverno CLI has a known limitation: pattern matching for substrings in multi-line string fields (e.g., `ConfigMap.data.logging`) does not always work as expected in CLI tests, even though it works in real clusters. For these, supplement CLI tests with manual review or a custom script, and consider raising an issue with the Kyverno project. 

---

**Test Automation Note:**
All policies and test cases are now automated and passing using `./scripts/test-all-policies.sh`. However, for the controls listed above, passing tests may only indicate partial coverage or syntactic validation, not full enforcement of the CIS intent. Manual review or AWS-side validation may still be required for full compliance assurance. 