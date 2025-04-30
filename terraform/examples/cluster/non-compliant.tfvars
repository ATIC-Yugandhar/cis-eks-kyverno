# Terraform variables for the NON-COMPLIANT EKS cluster example
# NOTE: This configuration is intended for testing non-compliant scenarios.
# Do NOT use this configuration for production environments.

mode = "noncompliant"

# Most variables will use the defaults defined in main.tf.
# Override specific variables below if needed for your non-compliant test setup.

# Example: Specify allowed CIDR for SSH if needed (replace with actual IP/range)
# allowed_ingress_cidr_blocks = ["YOUR_IP/32"]

# Example: Customize tags
# tags = {
#   Environment = "testing"
#   Project     = "non-compliant-cluster"
#   Owner       = "test-team"
# }