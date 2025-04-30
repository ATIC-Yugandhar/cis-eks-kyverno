output "kms_key_arn" {
  description = "The ARN of the KMS key used for EKS secrets encryption."
  # Return the ARN only if the key was created, otherwise null
  value = var.enable_kms_encryption ? aws_kms_key.eks_secrets[0].arn : null
}