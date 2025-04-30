# --- EKS Cluster IAM Role ---
resource "aws_iam_role" "cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    {
      Name = "${var.cluster_name}-cluster-role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# Optional: Attach AmazonEKSVPCResourceController policy if using security groups for pods
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  count      = var.enable_vpc_resource_controller_policy ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_role.name
}

# --- EKS Node Group IAM Role ---
resource "aws_iam_role" "node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    {
      Name = "${var.cluster_name}-node-role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

# Compliant: Attach CNI Policy
resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy_compliant" {
  count      = var.compliant_iam ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

# Non-Compliant: Potentially attach broader policies or skip CNI policy if desired
# Example: Attach a more permissive policy for non-compliant setup
# resource "aws_iam_role_policy_attachment" "node_SomeBroaderPolicy_noncompliant" {
#   count      = !var.compliant_iam ? 1 : 0
#   policy_arn = "arn:aws:iam::aws:policy/SomeOtherPolicy" # Replace with actual policy
#   role       = aws_iam_role.node_role.name
# }

# Attach custom policies if provided
resource "aws_iam_role_policy_attachment" "node_custom" {
  for_each   = toset(var.node_additional_policy_arns)
  policy_arn = each.value
  role       = aws_iam_role.node_role.name
}