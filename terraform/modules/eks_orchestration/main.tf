# --- Orchestration Module: eks_orchestration ---
# This module conditionally calls sub-modules to create either a
# CIS-compliant or a non-compliant EKS cluster based on the 'is_compliant' variable.

locals {
  # Determine effective settings based on compliance mode
  effective_enable_kms_encryption   = var.is_compliant || var.enable_kms_encryption
  effective_endpoint_private_access = var.is_compliant ? true : var.endpoint_private_access
  effective_endpoint_public_access  = var.is_compliant ? false : var.endpoint_public_access
  effective_public_access_cidrs     = var.is_compliant ? [] : var.endpoint_public_access_cidrs
  compliant_log_types               = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  effective_enabled_log_types       = var.is_compliant ? local.compliant_log_types : var.enabled_cluster_log_types
  effective_sg_allowed_cidrs        = var.is_compliant ? null : var.sg_allowed_ingress_cidr_blocks # Pass null to SG module if compliant, it uses its own stricter default
}

# --- Networking (Common) ---
module "networking" {
  source = "../networking"

  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  # Use one() for safer access to conditional module output - CORRECTED attribute name
  kms_key_arn_for_logs = local.effective_enable_kms_encryption ? one(module.kms[*].kms_key_arn) : null
  tags                 = var.tags
}

# --- IAM (Conditional Compliance) ---
module "iam" {
  source = "../iam"

  cluster_name                          = var.cluster_name
  tags                                  = var.tags
  enable_vpc_resource_controller_policy = var.enable_vpc_resource_controller_policy
  compliant_iam                         = var.is_compliant # Directly use the flag
  node_additional_policy_arns           = var.node_additional_policy_arns
}

# --- KMS (Conditional Creation) ---
module "kms" {
  count  = local.effective_enable_kms_encryption ? 1 : 0 # Create only if KMS is enabled (either by compliance or flag)
  source = "../kms"

  cluster_name                    = var.cluster_name
  aws_region                      = var.aws_region
  enable_kms_encryption           = true # This module is only created when encryption is desired
  kms_key_deletion_window_in_days = var.kms_key_deletion_window_in_days
  tags                            = var.tags
}

# --- Security Groups (Conditional Compliance) ---
module "security_groups" {
  source = "../security_groups"

  cluster_name                = var.cluster_name
  vpc_id                      = module.networking.vpc_id
  tags                        = var.tags
  compliant_rules             = var.is_compliant                 # Directly use the flag
  allowed_ingress_cidr_blocks = local.effective_sg_allowed_cidrs # Pass specific CIDRs only if non-compliant
}

# --- EKS Cluster & Node Group (Conditional Settings) ---
# --- EKS Cluster & Node Group ---
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = module.iam.cluster_role_arn

  vpc_config {
    subnet_ids              = module.networking.private_subnet_ids # Defaulting to private for base resource
    security_group_ids      = [module.security_groups.cluster_security_group_id]
    endpoint_private_access = local.effective_endpoint_private_access
    endpoint_public_access  = local.effective_endpoint_public_access
    public_access_cidrs     = local.effective_public_access_cidrs
  }

  enabled_cluster_log_types = local.effective_enabled_log_types

  dynamic "encryption_config" {
    for_each = local.effective_enable_kms_encryption ? [1] : []
    content {
      resources = ["secrets"]
      provider {
        key_arn = module.kms[0].kms_key_arn
      }
    }
  }

  tags = var.tags
}

resource "aws_eks_node_group" "primary" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-primary-nodes"
  node_role_arn   = module.iam.node_role_arn
  subnet_ids      = module.networking.private_subnet_ids # Nodes typically in private subnets

  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  dynamic "remote_access" {
    for_each = var.node_ssh_key_name != null ? [1] : []
    content {
      ec2_ssh_key               = var.node_ssh_key_name
      source_security_group_ids = var.node_ssh_access_security_group_ids # Assuming this variable exists
    }
  }

  tags = merge(var.tags, var.node_group_tags)

  depends_on = [
    aws_eks_cluster.this,
    module.iam # Ensure IAM roles are created before node group
  ]
}