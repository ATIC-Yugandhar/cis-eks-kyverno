output "cluster_role_arn" {
  description = "The ARN of the EKS cluster IAM role."
  value       = aws_iam_role.cluster_role.arn
}

output "node_role_arn" {
  description = "The ARN of the EKS node group IAM role."
  value       = aws_iam_role.node_role.arn
}