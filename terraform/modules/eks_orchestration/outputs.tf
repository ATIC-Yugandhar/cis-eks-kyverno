 # --- Outputs from Orchestration Module ---

output "vpc_id" {
  description = "The ID of the VPC created by the networking module."
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "A list of IDs for the private subnets created by the networking module."
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "A list of IDs for the public subnets created by the networking module."
  value       = module.networking.public_subnet_ids
}

output "cluster_role_arn" {
  description = "The ARN of the EKS cluster IAM role created by the IAM module."
  value       = module.iam.cluster_role_arn
}

output "node_role_arn" {
  description = "The ARN of the EKS node group IAM role created by the IAM module."
  value       = module.iam.node_role_arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key created by the KMS module (if enabled)."
  # If KMS module count is 0, this returns null. If 1, returns the ARN.
  value = one(module.kms[*].kms_key_arn)
}

output "cluster_security_group_id" {
  description = "The ID of the EKS cluster security group created by the security_groups module."
  value       = module.security_groups.cluster_security_group_id
}

output "node_security_group_id" {
  description = "The ID of the EKS node security group created by the security_groups module."
  value       = module.security_groups.node_security_group_id
}

output "cluster_id" {
  description = "The name/id of the EKS cluster created by the eks_cluster module."
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_group_id" {
  description = "The ID of the default EKS node group created by the eks_cluster module."
  value       = aws_eks_node_group.primary.id
}

output "node_group_status" {
  description = "The status of the default EKS node group created by the eks_cluster module."
  value       = aws_eks_node_group.primary.status
}