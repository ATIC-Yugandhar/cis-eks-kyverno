# --- KMS Resources ---

# --- KMS Key for EKS Secrets Encryption ---
data "aws_caller_identity" "current" {} # Needed for the default policy

resource "aws_kms_key" "eks_secrets" {
  count                   = var.enable_kms_encryption ? 1 : 0 # Only create if enabled
  description             = "KMS key for ${var.cluster_name} EKS secrets encryption"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true # CIS 1.1.3 recommends enabling rotation

  # Key policy: Allow EKS service to use the key for encryption/decryption
  # This is a basic policy, refine based on least privilege principles if needed
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "eks-secrets-kms-policy",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          # Allows root user of the account executing Terraform full control
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow EKS Service to use the key",
        Effect = "Allow",
        Principal = {
          Service = "eks.${var.aws_region}.amazonaws.com" # Use aws_region variable
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*" # Resource is '*' because the key ARN isn't known until creation
        # Condition to potentially restrict further if needed
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.cluster_name}-eks-secrets-key"
    },
    var.tags
  )
}