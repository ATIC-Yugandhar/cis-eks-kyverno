variable "cluster_name" {
  description = "The name of the EKS cluster, used for naming resources."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
variable "kms_key_arn_for_logs" {
  description = "Optional KMS Key ARN to encrypt the VPC Flow Logs CloudWatch Log Group."
  type        = string
  default     = null
}