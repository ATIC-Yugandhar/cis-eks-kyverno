variable "cluster_name" {
  description = "The name of the EKS cluster, used for naming resources."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "enable_vpc_resource_controller_policy" {
  description = "Whether to attach the AmazonEKSVPCResourceController policy to the cluster role. Required if using security groups for pods."
  type        = bool
  default     = false
}

variable "compliant_iam" {
  description = "Boolean flag to enable stricter, compliant IAM policies (e.g., attaching CNI policy)."
  type        = bool
  default     = true # Default to compliant policies
}

variable "node_additional_policy_arns" {
  description = "List of additional policy ARNs to attach to the EKS node role."
  type        = list(string)
  default     = []
}