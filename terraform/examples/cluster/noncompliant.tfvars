# Terraform variables for the NON-COMPLIANT EKS cluster example

mode = "noncompliant"

# Override defaults from main.tf for a non-compliant setup

cluster_name = "eks-cluster-noncompliant-example"

# Networking (using defaults, but could be overridden)
# vpc_cidr             = "10.1.0.0/16"
# private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
# public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24"]

# Disable KMS encryption
enable_kms_encryption = false

# Less strict IAM (handled by mode = "noncompliant" in main.tf)

# Less strict Security Groups (handled by mode = "noncompliant" in main.tf)

# Enable public endpoint access and allow all IPs (less secure)
endpoint_private_access      = false # Can be true or false depending on test case
endpoint_public_access       = true
endpoint_public_access_cidrs = ["0.0.0.0/0"]

# Disable cluster logging
enabled_cluster_log_types = []

# Example: Use smaller/cheaper instances for testing
# node_instance_types = ["t3.micro"]
# node_desired_size   = 1
# node_max_size       = 1
# node_min_size       = 1

# Example: Customize tags
# tags = {
#   Environment = "development"
#   Project     = "noncompliant-cluster-test"
#   Owner       = "dev-team"
# }