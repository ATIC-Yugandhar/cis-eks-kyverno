# --- General Configuration ---
variable "cluster_name" {
  description = "The name for the EKS cluster and associated resources."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

# --- Compliance Mode ---
variable "is_compliant" {
  description = "If true, enforces CIS-compliant settings. If false, uses less strict settings."
  type        = bool
  default     = true
}

# --- Networking ---
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for private subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for public subnets."
  type        = list(string)
}

# --- IAM ---
variable "enable_vpc_resource_controller_policy" {
  description = "Whether to attach the VPC Resource Controller policy to the cluster role."
  type        = bool
  default     = true # Recommended for CSI driver etc.
}

variable "node_additional_policy_arns" {
  description = "List of additional policy ARNs to attach to the EKS node IAM role."
  type        = list(string)
  default     = []
}

# --- KMS (Conditional) ---
variable "enable_kms_encryption" {
  description = "Flag to enable KMS encryption for EKS secrets. Forced true if is_compliant is true."
  type        = bool
  default     = false # Default to false for non-compliant mode
}

variable "kms_key_deletion_window_in_days" {
  description = "The waiting period, in days, before deleting the KMS key."
  type        = number
  default     = 7
}

# --- Security Groups ---
variable "sg_allowed_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed for ingress to the cluster control plane. Only used if is_compliant is true."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Default for non-compliant, ignored if compliant=true (uses stricter default there)
}

# --- EKS Cluster ---
variable "cluster_version" {
  description = "The desired Kubernetes version for the EKS cluster."
  type        = string
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Forced true if is_compliant is true."
  type        = bool
  default     = false # Default for non-compliant
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Forced false if is_compliant is true."
  type        = bool
  default     = true # Default for non-compliant
}

variable "endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public endpoint. Forced empty list [] if is_compliant is true."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Default for non-compliant
}

variable "enabled_cluster_log_types" {
  description = "A list of the desired control plane logging to enable. Uses compliant defaults if is_compliant is true, otherwise uses this value (defaulting to empty)."
  type        = list(string)
  default     = [] # Default for non-compliant
}

# --- EKS Node Group ---
variable "node_instance_types" {
  description = "List of instance types for the EKS node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_disk_size" {
  description = "Disk size in GiB for nodes."
  type        = number
  default     = 20
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group."
  type        = number
  default     = 1
}

variable "node_ssh_key_name" {
  description = "Name of the SSH key pair to associate with the nodes for SSH access (optional)."
  type        = string
  default     = null
}

variable "node_ssh_access_security_group_ids" {
  description = "List of security group IDs to allow SSH access to nodes. Only relevant if node_ssh_key_name is set."
  type        = list(string)
  default     = []
}

variable "node_group_tags" {
  description = "Additional tags to apply specifically to the EKS node group resources."
  type        = map(string)
  default     = {}
}