terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

variable "mode" {
  description = "Deployment mode: 'compliant' or 'noncompliant'."
  type        = string
  default     = "compliant" # Default to compliant

  validation {
    condition     = contains(["compliant", "noncompliant"], var.mode)
    error_message = "Mode must be either 'compliant' or 'noncompliant'."
  }
}

variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "eks-cluster-example"
}

variable "cluster_version" {
  description = "Desired Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.28" # Specify a default version
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_kms_encryption" {
  description = "Boolean flag to enable KMS encryption for EKS secrets. Typically true for compliant mode."
  type        = bool
  default     = true
}

variable "kms_key_deletion_window_in_days" {
  description = "The waiting period, in days, before deleting the KMS key (if created)."
  type        = number
  default     = 7
}

variable "enable_vpc_resource_controller_policy" {
  description = "Whether to attach the AmazonEKSVPCResourceController policy to the cluster role. Required if using security groups for pods."
  type        = bool
  default     = true # Often needed, especially for compliant setups using SG for pods
}

variable "node_additional_policy_arns" {
  description = "List of additional policy ARNs to attach to the EKS node role."
  type        = list(string)
  default     = []
}

variable "allowed_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed for ingress in compliant security group rules (e.g., for SSH)."
  type        = list(string)
  default     = [] # Default to no extra access
}

variable "endpoint_private_access" {
  description = "Indicates whether the Amazon EKS private API server endpoint is enabled. Typically true for compliant mode."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Indicates whether the Amazon EKS public API server endpoint is enabled. Typically false for compliant mode."
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public endpoint (if enabled)."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Default to open if public access is enabled (non-compliant)
}

variable "enabled_cluster_log_types" {
  description = "A list of the desired control plane logging to enable (e.g., api, audit, authenticator). Recommended for compliant mode."
  type        = list(string)
  # Default to recommended logs for compliance
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

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
  description = "The SSH key name to allow remote access to nodes (optional)."
  type        = string
  default     = null
}

variable "node_ssh_access_security_group_ids" {
  description = "List of security group IDs allowed to connect via SSH to nodes (if SSH key is provided)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "node_group_tags" {
  description = "A map of tags to assign specifically to the node group resources."
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# Modules
# ------------------------------------------------------------------------------

module "eks_orchestration" {
  source = "../../modules/eks_orchestration"

  # --- General & Compliance ---
  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  tags         = var.tags
  is_compliant = var.mode == "compliant"

  # --- Networking ---
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs

  # --- IAM ---
  enable_vpc_resource_controller_policy = var.enable_vpc_resource_controller_policy
  node_additional_policy_arns           = var.node_additional_policy_arns

  # --- KMS (Conditional) ---
  # Pass the root variable; the module decides based on is_compliant OR this flag
  enable_kms_encryption           = var.enable_kms_encryption
  kms_key_deletion_window_in_days = var.kms_key_deletion_window_in_days

  # --- Security Groups ---
  # Pass the root variable; the module ignores it if is_compliant is true
  sg_allowed_ingress_cidr_blocks = var.allowed_ingress_cidr_blocks

  # --- EKS Cluster ---
  cluster_version = var.cluster_version
  # Pass root variables; module overrides based on is_compliant
  endpoint_private_access      = var.endpoint_private_access
  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  enabled_cluster_log_types    = var.enabled_cluster_log_types

  # --- EKS Node Group ---
  node_instance_types                = var.node_instance_types
  node_disk_size                     = var.node_disk_size
  node_desired_size                  = var.node_desired_size
  node_max_size                      = var.node_max_size
  node_min_size                      = var.node_min_size
  node_ssh_key_name                  = var.node_ssh_key_name
  node_ssh_access_security_group_ids = var.node_ssh_access_security_group_ids
  node_group_tags                    = var.node_group_tags
}

# ------------------------------------------------------------------------------
# Outputs - Reference the orchestration module
# ------------------------------------------------------------------------------

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks_orchestration.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = module.eks_orchestration.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks_orchestration.cluster_id # Use cluster_id output from module
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the cluster."
  value       = module.eks_orchestration.cluster_oidc_issuer_url
}

output "vpc_id" {
  description = "The ID of the VPC created."
  value       = module.eks_orchestration.vpc_id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets."
  value       = module.eks_orchestration.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets."
  value       = module.eks_orchestration.public_subnet_ids
}

output "cluster_sg_id" {
  description = "ID of the cluster security group."
  value       = module.eks_orchestration.cluster_security_group_id
}

output "node_sg_id" {
  description = "ID of the node security group."
  value       = module.eks_orchestration.node_security_group_id
}

# Note: The orchestration module doesn't explicitly output node_ssh_sg_id
# If needed, it should be added to the orchestration module's outputs.tf
# output "node_ssh_sg_id" {
#   description = "ID of the node SSH security group (only created if ssh key provided)."
#   value       = module.eks_orchestration.node_ssh_sg_id
# }

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = module.eks_orchestration.cluster_role_arn
}

output "node_role_arn" {
  description = "ARN of the EKS node group IAM role."
  value       = module.eks_orchestration.node_role_arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for secrets encryption (if enabled)."
  value       = module.eks_orchestration.kms_key_arn # This will be null if KMS is not enabled
}