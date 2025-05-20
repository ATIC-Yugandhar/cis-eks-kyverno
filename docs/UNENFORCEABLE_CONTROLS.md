# Unenforceable or Partially Enforceable CIS EKS Controls with Kyverno (Plan Level)

This document lists all CIS EKS Benchmark controls that cannot be fully enforced by Kyverno JSON policies at the Terraform plan level, along with explanations and notes on test automation.

- The project uses plan-level Kyverno JSON policies (`kyverno-json`) to enforce as many CIS controls as possible before `terraform apply`.
- Controls listed here require runtime or AWS-side validation, or depend on values only known after apply.
- See `kyverno-policies/terraform/README.md` for enforceable policy details and plan-time limitations.
- See `reports/compliance/README.md` for automated report outputs.

| CIS ID  | Description                                              | Reason Not Enforceable at Plan Level             |
|---------|----------------------------------------------------------|--------------------------------------------------|
| 4.1.7   | Use Cluster Access Manager API                           | Full enforcement requires AWS IAM/API access. Partial validation of `aws_eks_access_entry` configurations is possible if defined in the Terraform plan. |
| 4.3.1   | Ensure CNI plugin supports network policies              | CNI plugin config is outside Terraform plan      |
| 4.4.2   | Use external secret storage                              | External secret storage is not a Terraform/K8s resource |
| 5.1.1   | Enable image scanning in ECR or third-party              | Full enforcement relies on ECR/3rd-party scanning status. If ECR repositories are managed via Terraform, the `scan_on_push` setting is directly verifiable at plan-time. |
| 5.1.2   | Minimize user access to ECR                              | Full enforcement can be complex due to policy subjectivity. Partial validation of relevant IAM and ECR policies is possible if defined in the Terraform plan. |
| 5.1.3   | Limit cluster ECR access to read-only                    | Full enforcement can be complex due to policy subjectivity. Partial validation of relevant IAM and ECR policies (ensuring read-only access for the cluster) is possible if defined in the Terraform plan. |
| 5.4.1   | Restrict control plane endpoint access                   | Directly enforceable if EKS cluster settings (`endpoint_public_access`, `public_access_cidrs`) are defined in the Terraform plan. Otherwise, requires AWS-side validation. |
| 5.4.3   | Deploy private nodes                                     | Node deployment is managed by AWS                |
| 5.4.5   | Use TLS to encrypt load balancer traffic                 | Verifiable if LoadBalancer Kubernetes Services or AWS Load Balancer resources (and their TLS configurations) are defined within the Terraform plan. Otherwise, requires AWS-side validation. |
| 5.5.1   | Manage users via IAM Authenticator or AWS CLI            | Full enforcement is complex. Partial validation of `aws-auth` ConfigMap or EKS Access Entries is possible if managed via Terraform. |

**Note:** Some controls are only partially enforceable (e.g., those requiring audit or external validation). For these, see the corresponding policy with `audit` mode and annotations.

---

**Plan-Time Limitation:**
For some controls (e.g., KMS encryption), the Terraform plan may only show the presence of a config block, not the resolved value (like a KMS key ARN). Policies are written to check for configuration presence where possible, but full enforcement may require post-apply validation.

---

**Test Automation Note:**
All plan-level policies and test cases are automated and validated using `./scripts/test-terraform-cis-policies.sh`. Controls listed above require additional manual or AWS-side review for full compliance assurance.

---

**Additional Limitation:**
For controls like 2.1.1 and 2.1.2 (audit logging), Kyverno CLI has a known limitation: pattern matching for substrings in multi-line string fields (e.g., `ConfigMap.data.logging`) does not always work as expected in CLI tests, even though it works in real clusters. For these, supplement CLI tests with manual review or a custom script, and consider raising an issue with the Kyverno project. 

---

**Test Automation Note:**
All policies and test cases are now automated and passing using `./scripts/test-all-policies.sh`. However, for the controls listed above, passing tests may only indicate partial coverage or syntactic validation, not full enforcement of the CIS intent. Manual review or AWS-side validation may still be required for full compliance assurance. 