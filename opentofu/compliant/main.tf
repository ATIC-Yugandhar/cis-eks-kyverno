provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(["${var.region}a", "${var.region}b", "${var.region}c"], count.index)
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
    Environment = "production"
    Owner       = "platform-team"
  }
}

# Custom Network ACL for CIS 5.1.2-nacl-configuration
resource "aws_network_acl" "custom" {
  vpc_id = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # Ingress rules
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 10250
    to_port    = 10250
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 53
    to_port    = 53
  }

  ingress {
    protocol   = "udp"
    rule_no    = 130
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 53
    to_port    = 53
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }

  # Egress rules
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = "udp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name        = "${var.cluster_name}-custom-nacl"
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}-nodes"
  description = "Node group security group"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_iam_role" "eks" {
  name = "cis-eks-compliant-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

# IAM role for EKS authentication (CIS 5.5.1-iam-authenticator and CIS 2.2.1-authorization-mode)
resource "aws_iam_role" "eks_auth" {
  name = "${var.cluster_name}-eks-auth-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
    Purpose     = "EKS IAM Authentication"
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# CIS 4.1.3 compliant policy - specific permissions only
resource "aws_iam_role_policy" "compliant_eks_logging_policy" {
  name = "eks-logging-policy"
  role = aws_iam_role.eks.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.region}:*:log-group:/aws/eks/${var.cluster_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "eks_node_group" {
  name = "${var.cluster_name}-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "ec2_container_registry" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Explicit ECR read-only policy for CIS 5.1.2-ecr-access-minimization
resource "aws_iam_role_policy" "ecr_read_only" {
  name = "${var.cluster_name}-ecr-read-only"
  role = aws_iam_role.eks_node_group.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
      }
    ]
  })
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  kubernetes_network_config {
    service_ipv4_cidr = "10.100.0.0/16"
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks.arn
    }
  }
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.main.name
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "compliant-ng"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = aws_subnet.private[*].id
  instance_types  = [var.node_instance_type]
  capacity_type   = "ON_DEMAND"
  ami_type        = "AL2_x86_64"  # Specify secure AMI type for CIS 3.1.1
  
  scaling_config {
    desired_size = var.desired_capacity
    min_size     = var.min_size
    max_size     = min(var.max_size, 100)  # CIS 5.5.1-resource-quotas: max_size must be <= 100
  }
  depends_on = [aws_security_group.nodes]
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

# CloudWatch Log Group for EKS audit logs (CIS 2.1.2, 2.1.3)
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 90
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

# ECR repository with image scanning enabled (CIS 5.1.1)
resource "aws_ecr_repository" "app" {
  name                 = "${var.cluster_name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

# Secrets Manager secret with KMS encryption (CIS 5.3.2)
resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${var.cluster_name}-app-secrets"
  description = "Application secrets for EKS cluster"
  kms_key_id  = aws_kms_key.eks.arn
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

# EKS Add-on for VPC CNI (CIS 4.3.1)
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "kubernetes_network_policy" "default_deny_all" {
  metadata {
    name      = "default-deny-all"
    namespace = "default"
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

# Configure IAM identity mapping for EKS authentication
resource "aws_eks_identity_provider_config" "oidc" {
  cluster_name = aws_eks_cluster.main.name

  oidc {
    client_id                     = "sts.amazonaws.com"
    identity_provider_config_name = "oidc-provider"
    issuer_url                    = aws_eks_cluster.main.identity[0].oidc[0].issuer
  }
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

# IAM OIDC provider for EKS
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
} 