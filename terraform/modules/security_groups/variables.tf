variable "cluster_name" {
  description = "The name of the EKS cluster, used for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security groups will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

# Variables to control compliant vs non-compliant rules
variable "compliant_rules" {
  description = "Boolean flag to enable stricter, compliant security group rules."
  type        = bool
  default     = true # Default to compliant rules
}

variable "allowed_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed for ingress (e.g., for SSH or specific APIs). Only used if compliant_rules is true."
  type        = list(string)
  default     = []
}