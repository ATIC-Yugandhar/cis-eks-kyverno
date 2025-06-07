# CIS-Compliant EKS Automation (Compliant Cluster)

**This stack provisions a reference CIS-compliant EKS cluster for validating plan-level Kyverno JSON policies. It is used as the gold standard for passing all enforceable CIS controls at the OpenTofu/Terraform plan stage.**

- Automated validation is performed using `scripts/test-opentofu-policies.sh`.
- See `policies/README.md` for policy organization and structure.

## Prerequisites

- [Kyverno CLI must be installed](https://kyverno.io/docs/installation/) locally and/or in your Kubernetes cluster.

---

## Overview
This module provisions a CIS-compliant EKS cluster, Kyverno, policies, and a private SSM-enabled EC2 instance for automation. All provisioning and policy application is designed to be run from inside the VPC for strict CIS compliance (no public EKS API endpoint).

## Workflow

1. **Provision Infrastructure**
   - Run `tofu apply` (or `terraform apply`) from your local machine or CI/CD to create the VPC, EKS, S3 bucket, and the SSM-enabled automation EC2 instance in a private subnet.

2. **Connect to the Automation Instance (via SSM)**
   - After `tofu apply`, get the SSM connect command:
     ```sh
     tofu -chdir=opentofu/compliant output automation_instance_ssm_command
     ```
   - Use the output command to start an SSM session:
     ```sh
     aws ssm start-session --target <instance-id> --region <region>
     ```
   - This gives you a shell inside the private subnet, with full access to the EKS API endpoint.

3. **Run OpenTofu and Automation Scripts from Inside the Instance**
   - Upload your code (e.g., via S3) or clone your repo inside the instance.
   - Run `tofu apply` from inside the instance to install Kyverno and apply policies.
   - Run your orchestrator/test scripts as needed.

4. **Cleanup**
   - You can run `tofu destroy` from inside the instance for full cleanup.

## Security & Compliance
- The EKS API endpoint is private-only (`endpoint_public_access = false`).
- The automation instance has no public IP and is only accessible via SSM Session Manager.
- All actions are auditable via AWS CloudTrail and SSM logs.

## Outputs
- `automation_instance_id`: The EC2 instance ID for automation.
- `automation_instance_ssm_command`: The SSM connect command for the instance.
- `automation_bucket`: The S3 bucket for automation artifacts.

---

**This approach ensures all provisioning and policy application is done from inside the VPC, meeting strict CIS requirements.** 