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

```sh
cd terraform/compliant
terraform init
terraform apply
```

This will provision a CIS-compliant EKS cluster.