provider "aws" {
  region = var.region
}

# --- Noncompliant: VPC with public subnets (public nodes) ---
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = element(["${var.region}a", "${var.region}b", "${var.region}c"], count.index)
  map_public_ip_on_launch = true
}

# --- Noncompliant: EKS Cluster with audit logging disabled, public endpoint, no encryption ---
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    endpoint_private_access = false   # Noncompliant: No private endpoint
    endpoint_public_access  = true    # Noncompliant: Public endpoint
  }

  enabled_cluster_log_types = [] # Noncompliant: Audit logging disabled

  kubernetes_network_config {
    service_ipv4_cidr = "10.100.0.0/16"
  }

  # No encryption_config block (noncompliant)
}

# --- Noncompliant: No KMS key for encryption ---
# (Intentionally omitted)

# --- Noncompliant: OIDC/IAM for Service Accounts not enabled ---
resource "aws_iam_role" "eks" {
  name = "${var.cluster_name}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# --- Noncompliant: Node Group in public subnets ---
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "noncompliant-ng"
  node_role_arn   = aws_iam_role.eks.arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = [var.node_instance_type]
  scaling_config {
    desired_size = var.desired_capacity
    min_size     = var.min_size
    max_size     = var.max_size
  }
}

# --- Install Kyverno (Helm) ---
resource "helm_release" "kyverno" {
  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = "3.0.0"
  namespace  = "kyverno"
  create_namespace = true
}

# --- (Optional) Apply Kyverno policies via kubernetes_manifest or kubectl ---
# See scripts for automation 