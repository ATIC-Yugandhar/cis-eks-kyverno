# --- Security Groups ---
locals {
  # Condition to create the compliant SSH ingress rule block
  # Evaluate the condition safely here to avoid potential length(null) errors in for_each
  create_compliant_ssh_rule = (var.compliant_rules && var.allowed_ingress_cidr_blocks != null ? length(var.allowed_ingress_cidr_blocks) > 0 : false)
}

resource "aws_security_group" "cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for the EKS cluster control plane"
  vpc_id      = var.vpc_id

  # EKS Managed Rules: EKS automatically manages rules needed for communication
  # between the control plane and managed node groups when this SG is associated
  # with the cluster. Avoid adding conflicting rules here.

  # Compliant: Ensure all egress is blocked by default if not managed by EKS.
  # Non-Compliant: Allow all egress by default.
  dynamic "egress" {
    for_each = var.compliant_rules ? [] : [1] # Only add for non-compliant
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic (Non-Compliant)"
    }
  }

  tags = merge(
    {
      Name = "${var.cluster_name}-cluster-sg"
    },
    var.tags
  )
}

resource "aws_security_group" "node_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for the EKS worker nodes"
  vpc_id      = var.vpc_id

  # --- Common Ingress Rules ---
  ingress {
    from_port       = 0 # Allow all traffic from the cluster SG for control plane communication
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.cluster_sg.id]
    description     = "Allow communication from Cluster Control Plane"
  }

  ingress {
    from_port   = 0 # Allow traffic within the node group itself
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow nodes to communicate with each other"
  }

  # --- Compliant Specific Ingress Rules ---
  dynamic "ingress" {
    for_each = local.create_compliant_ssh_rule ? [1] : []
    content {
      from_port   = 22 # SSH Port
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ingress_cidr_blocks
      description = "Allow SSH access from specified CIDRs (Compliant)"
    }
  }
  # Potentially add rules for NodePort range if needed for compliant setup

  # --- Non-Compliant Specific Ingress Rules ---
  # Example: Allow all HTTP/HTTPS ingress for non-compliant setup
  dynamic "ingress" {
    for_each = !var.compliant_rules ? [80, 443] : []
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow world HTTP/HTTPS access (Non-Compliant)"
    }
  }

  # --- Common Egress Rules ---
  # Allow nodes to talk back to the control plane API
  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster_sg.id]
    description     = "Allow nodes egress to cluster control plane (HTTPS API)"
  }

  # --- Compliant Specific Egress Rules ---
  dynamic "egress" {
    for_each = var.compliant_rules ? [1] : []
    content {
      from_port   = 443 # Allow outbound HTTPS for pulling images, AWS APIs etc.
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow outbound HTTPS (Compliant)"
    }
  }
  dynamic "egress" {
    for_each = var.compliant_rules ? [1] : []
    content {
      from_port   = 53 # Allow outbound DNS
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow outbound DNS (UDP) (Compliant)"
    }
  }
  dynamic "egress" {
    for_each = var.compliant_rules ? [1] : []
    content {
      from_port   = 53 # Allow outbound DNS
      to_port     = 53
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow outbound DNS (TCP) (Compliant)"
    }
  }
  # Add other specific egress rules as needed (e.g., NTP)

  # --- Non-Compliant Specific Egress Rules ---
  dynamic "egress" {
    for_each = !var.compliant_rules ? [1] : []
    content {
      from_port   = 0 # Allow all outbound traffic
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic (Non-Compliant)"
    }
  }


  tags = merge(
    {
      Name                                        = "${var.cluster_name}-node-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
    var.tags
  )
}

# --- Rules between Cluster and Node SGs ---
# These ensure the control plane can reach nodes and vice-versa on necessary ports.
# EKS might manage some of these automatically for managed node groups.

# Allow Control Plane -> Node Communication (e.g., kubelet health checks, exec/logs)
resource "aws_security_group_rule" "cluster_to_node_kubelet" {
  type                     = "ingress"
  from_port                = 10250 # Kubelet API
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.cluster_sg.id
  description              = "Allow Cluster Control Plane to Kubelet"
}

# Allow Node -> Control Plane Communication (already handled by node_sg egress rule)
# resource "aws_security_group_rule" "node_to_cluster_api" {
#   type                     = "egress" # This rule type is often confusing, handled in node_sg egress
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.node_sg.id
#   source_security_group_id = aws_security_group.cluster_sg.id # Destination SG for egress
#   description              = "Allow worker nodes egress to cluster control plane (HTTPS API)"
# }

# Allow Cluster -> Node Communication (HTTPS for webhooks etc.)
resource "aws_security_group_rule" "cluster_to_node_https_webhooks" {
  type                     = "ingress"
  from_port                = 443 # For webhooks, aggregated API servers etc. running on nodes
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.cluster_sg.id
  description              = "Allow Cluster Control Plane to Node webhooks/API"
}