# Terraform variables for the COMPLIANT EKS cluster example

mode = "compliant"

# Most variables will use the defaults defined in main.tf, which are set for compliance.
# Override specific variables below if needed for your compliant setup.

# Example: Specify allowed CIDR for SSH if needed (replace with actual IP/range)
# allowed_ingress_cidr_blocks = ["YOUR_IP/32"]

# Example: Customize tags
# tags = {
#   Environment = "production"
#   Project     = "compliant-cluster"
#   Owner       = "security-team"
# }