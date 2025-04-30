output "cluster_security_group_id" {
  description = "The ID of the EKS cluster security group."
  value       = aws_security_group.cluster_sg.id
}

output "node_security_group_id" {
  description = "The ID of the EKS node security group."
  value       = aws_security_group.node_sg.id
}