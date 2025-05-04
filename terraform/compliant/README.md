# Compliant EKS Cluster

This configuration provisions an Amazon EKS cluster that is fully aligned with CIS Kubernetes Benchmark controls.

## Key Compliance Features

- **VPC**: Private subnets for worker nodes, NAT gateway enabled, DNS support enabled.
- **EKS Cluster**:
  - Control plane logging enabled for all types (`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`).
  - Public endpoint access disabled; only private endpoint enabled.
  - IAM Roles for Service Accounts (IRSA) enabled.
  - Managed node group runs in private subnets.
- **Terraform Modules**: Uses official AWS modules for VPC and EKS.

## Variables

| Name             | Description                        | Default                       |
|------------------|------------------------------------|-------------------------------|
| region           | AWS region                         | us-west-2                     |
| vpc_cidr         | VPC CIDR block                     | 10.0.0.0/16                   |
| azs              | Availability zones                 | us-west-2a,2b,2c              |
| private_subnets  | Private subnet CIDRs               | 10.0.1.0/24, 10.0.2.0/24...   |
| public_subnets   | Public subnet CIDRs                | 10.0.101.0/24, ...            |
| cluster_name     | EKS cluster name                   | compliant-eks-cluster         |
| cluster_version  | Kubernetes version                 | 1.29                          |

## Usage

The compliant workflow is now fully automated. **No manual SSH key creation or input is required.**

To provision the CIS-compliant EKS cluster and run the compliance workflow, use:

```sh
./scripts/compliant.sh
```

This script will:
- Automatically generate an SSH private key at `terraform/compliant/bastion_key.pem` (added to `.gitignore`).
- Provision the compliant EKS cluster and bastion host.
- Wait for the bastion host to become SSH-ready.
- Copy Kyverno policies, manifests, and the script to the bastion.
- Remotely run the compliance workflow on the bastion, including:
  - Installing required tools (AWS CLI, kubectl, Kyverno CLI, Helm).
  - Setting up kubeconfig for the EKS cluster.
  - Deploying Kyverno and applying all policies.
  - Deploying test workloads.
  - Running a compliance scan and generating a report.

The compliance report will be copied back to your local machine at `docs/compliance-report-compliant.md`.

### Notes

- The SSH private key is generated automatically and stored at `terraform/compliant/bastion_key.pem`. You do **not** need to create or provide a key.
- Ensure AWS credentials are available on the bastion (via IAM role or `aws configure`).
- If you need to re-run the workflow, ensure policies and manifests are up to date on the bastion.
- Do **not** destroy or modify the running cluster with this script.

For troubleshooting or advanced usage, see comments in `scripts/compliant.sh`.