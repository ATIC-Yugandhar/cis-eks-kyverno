# Terraform variables for the COMPLIANT EKS cluster example

# General
mode         = "compliant"
aws_region   = "us-east-1"
cluster_name = "cis-eks-kyverno-example"
tags = {
  Environment = "Example"
  Project     = "CIS-EKS-Kyverno"
}
is_compliant = true # Added to satisfy module requirement

# Networking
vpc_cidr             = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

# EKS Cluster & Nodes
cluster_version     = "1.29"
node_instance_types = ["t3.medium"]
node_disk_size      = 20
node_desired_size   = 2
node_max_size       = 3
node_min_size       = 1
# node_ssh_key_name = "your-ssh-key-name" # Optional: Add your key name for SSH access

# --- CIS Compliance Settings ---
# These override defaults or non-compliant settings when mode = "compliant"

# CIS 2.1.1 & 2.1.2: Enable specific logs and ensure they are managed (sent to CloudWatch)
enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_logging = true

# CIS 3.1.1 - 3.2.9: Explicitly set all compliance-critical kubelet settings (visible in Terraform plan)
kubelet_anonymous_auth                = false
kubelet_client_ca_file                = "/etc/kubernetes/pki/ca.crt"
kubelet_authorization_mode            = "Webhook"
kubelet_read_only_port                = 0
kubelet_streaming_connection_idle_timeout = "5m"
kubelet_make_iptables_util_chains     = true
kubelet_rotate_certificates           = true
kubelet_feature_gates                 = { RotateKubeletServerCertificate = true }
kubelet_protect_kernel_defaults       = true
kubelet_event_qps                     = 0
kubelet_config_json                   = ""

# node_user_data_compliant = true # DEPRECATED: compliance-critical settings are now explicit

# CIS 4.1.7: Use EKS Cluster Access Manager (Requires further implementation if true)
use_cluster_access_manager = true # Set to true to indicate intent

# CIS 4.4.2: Use external secret storage (KMS for EBS is handled by node group config)
# No specific variable here, relies on node group EBS encryption (implicitly enabled with launch template)

# CIS 5.1.1: Enable ECR Scan on Push (Requires managing ECR repos, set true for intent)
enable_ecr_scanning = true

# CIS 5.1.3: Enforce ReadOnly ECR access for nodes
enable_readonly_ecr_access = true

# CIS 5.3.1: Encrypt secrets with KMS
enable_kms_encryption = true

# CIS 5.4.1: Restrict Control Plane Access (Handled by setting public_access=false)
# endpoint_public_access_cidrs is ignored when public_access=false

# CIS 5.4.2: Use Private Endpoint
endpoint_private_access = true
endpoint_public_access  = false

# CIS 5.4.3: Use Private Subnets for Nodes
use_private_subnets_for_nodes = true

# CIS 5.4.5: Use TLS for Load Balancers (Requires managing LBs, set true for intent)
enable_tls_for_lb = true

# CIS 5.5.1: EKS Auth via IAM (Default EKS behavior, no specific variable needed)

# Other Settings (can be adjusted)
kms_key_deletion_window_in_days = 7
enable_vpc_resource_controller_policy = true # Recommended for CSI driver
# allowed_ingress_cidr_blocks = ["YOUR_IP/32"] # Ignored in compliant mode (uses SG)
# node_additional_policy_arns = []
