variable "cluster_name" {
  description = "The name of the EKS cluster, used for naming resources."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources are created."
  type        = string
}

variable "enable_kms_encryption" {
  description = "Boolean flag to enable KMS encryption for EKS secrets."
  type        = bool
  default     = true # Default to enabled for compliance
}

variable "kms_key_deletion_window_in_days" {
  description = "The waiting period, in days, before deleting the KMS key."
  type        = number
  default     = 7 # Minimum allowed value
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}