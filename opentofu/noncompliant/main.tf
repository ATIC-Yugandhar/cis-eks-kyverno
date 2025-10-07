provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  # Missing tags (violates require-tags policy)
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = element(["${var.region}a", "${var.region}b", "${var.region}c"], count.index)
  map_public_ip_on_launch = true
  # Missing tags (violates require-tags policy)
}

resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}-nodes"
  description = "Node group security group"
  vpc_id      = aws_vpc.main.id

  # Overly permissive security group rules (violates CIS 5.1.1)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH from anywhere (violates CIS)
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  # Missing tags (violates require-tags policy)
}

resource "aws_iam_role" "eks" {
  name = "${var.cluster_name}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
  # Missing tags (violates require-tags policy)
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
  # Missing tags (violates require-tags policy)
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
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

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    endpoint_private_access = false  # Violates CIS 5.4.2 (should be true)
    endpoint_public_access  = true   # Violates CIS 5.4.3 (should be false)
  }

  # No audit logging enabled (violates CIS 2.1.1, 2.1.2, 2.1.3)
  enabled_cluster_log_types = []

  kubernetes_network_config {
    service_ipv4_cidr = "10.100.0.0/16"
  }

  # No encryption config (violates CIS 5.3.1)
  # Missing tags (violates require-tags policy)
}

# Non-compliant launch template (violates CIS 3.1.1 and 3.2.1)
resource "aws_launch_template" "noncompliant_nodes" {
  name_prefix   = "${var.cluster_name}-noncompliant-"
  instance_type = var.node_instance_type
  
  vpc_security_group_ids = [aws_security_group.nodes.id]
  
  # No user data script - relies on default EKS configuration
  # This results in:
  # - Default file permissions (may not be CIS compliant)
  # - Anonymous authentication enabled by default
  # - No explicit kubelet security configuration
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-noncompliant-node"
      # Missing standard tags (violates require-tags policy)
    }
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "noncompliant-ng"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = aws_subnet.public[*].id  # Public subnets (violates CIS 5.4.3)
  
  # Use non-compliant launch template
  launch_template {
    id      = aws_launch_template.noncompliant_nodes.id
    version = aws_launch_template.noncompliant_nodes.latest_version
  }
  
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }
  depends_on = [aws_security_group.nodes]
  # Missing tags (violates require-tags policy)
}

# Create insecure ECR repository (violates CIS 5.1.1)
resource "aws_ecr_repository" "insecure_app" {
  name                 = "${var.cluster_name}-insecure-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false  # Violates CIS 5.1.1
  }
  # Missing tags (violates require-tags policy)
}

# Create unencrypted secrets (violates CIS 5.3.2)
resource "aws_secretsmanager_secret" "insecure_secrets" {
  name        = "${var.cluster_name}-insecure-secrets"
  description = "Insecure secrets without KMS encryption"
  # No kms_key_id specified (violates CIS 5.3.2)
  # Missing tags (violates require-tags policy)
}

# Create overly permissive IAM role (violates multiple CIS policies)
resource "aws_iam_role" "overprivileged_role" {
  name = "${var.cluster_name}-overprivileged-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "*"  # Too permissive
      },
      Action = "sts:AssumeRole"
    }]
  })
  # Missing tags (violates require-tags policy)
}

# Attach overly broad permissions
resource "aws_iam_role_policy" "overprivileged_policy" {
  name = "overprivileged-policy"
  role = aws_iam_role.overprivileged_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "*"  # Violates CIS 4.1.1, 4.1.2, 4.1.3, 4.1.4
      Resource = "*"
    }]
  })
}

# Missing required AWS resources that would be caught by policies:
# - No CloudWatch log group (violates CIS 2.1.2, 2.1.3)
# - No EKS add-ons (violates CIS 4.3.1) 
# - No network policies (violates CIS 5.4.4) 