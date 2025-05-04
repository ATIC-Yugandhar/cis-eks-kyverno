# Noncompliant EKS Cluster

This configuration provisions an Amazon EKS cluster that intentionally violates several CIS Kubernetes Benchmark controls for demonstration or testing purposes.

## Key Noncompliance Features

- **VPC**: Public subnets used for worker nodes, NAT gateway and DNS support disabled.
- **EKS Cluster**:
  - Control plane logging disabled.
  - Public endpoint access enabled; private endpoint disabled.
  - IAM Roles for Service Accounts (IRSA) disabled.
  - Managed node group runs in public subnets.
- **Terraform Modules**: Uses official AWS modules for VPC and EKS.

## Variables

| Name             | Description                        | Default                       |
|------------------|------------------------------------|-------------------------------|
| region           | AWS region                         | us-west-2                     |
| vpc_cidr         | VPC CIDR block                     | 10.1.0.0/16                   |
| azs              | Availability zones                 | us-west-2a,2b,2c              |
| private_subnets  | Private subnet CIDRs (unused)      | 10.1.1.0/24, 10.1.2.0/24...   |
| public_subnets   | Public subnet CIDRs                | 10.1.101.0/24, ...            |
| cluster_name     | EKS cluster name                   | noncompliant-eks-cluster      |
| cluster_version  | Kubernetes version                 | 1.29                          |

## Usage

```sh
cd terraform/noncompliant
terraform init
terraform apply
```

This will provision a noncompliant EKS cluster for testing or validation scenarios.