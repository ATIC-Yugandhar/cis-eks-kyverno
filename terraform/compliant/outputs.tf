output "region" {
  description = "AWS region to deploy resources in"
  value       = var.region
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
} 