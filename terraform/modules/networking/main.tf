# --- Networking Resources ---

data "aws_availability_zones" "available" {}

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${var.cluster_name}-vpc"
    },
    var.tags
  )
}

# --- Subnets ---
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name                                        = "${var.cluster_name}-private-subnet-${data.aws_availability_zones.available.names[count.index]}"
      "kubernetes.io/role/internal-elb"           = "1" # Required for internal load balancers
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Required for NAT Gateway/Instance in public subnet

  tags = merge(
    {
      Name                                        = "${var.cluster_name}-public-subnet-${data.aws_availability_zones.available.names[count.index]}"
      "kubernetes.io/role/elb"                    = "1" # Required for public load balancers
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
    var.tags
  )
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.cluster_name}-igw"
    },
    var.tags
  )
}

# --- NAT Gateway ---
# Optional but recommended for outbound connectivity from private subnets
resource "aws_eip" "nat" {
  count = length(aws_subnet.public) # Create one EIP per public subnet/AZ for HA

  # domain = "vpc" # Use 'vpc' for EIPs associated with VPC resources like NAT Gateways
  # depends_on = [aws_internet_gateway.gw] # Ensure IGW is created first

  tags = merge(
    {
      Name = "${var.cluster_name}-nat-eip-${data.aws_availability_zones.available.names[count.index]}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat" {
  count         = length(aws_subnet.public)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.cluster_name}-nat-gw-${data.aws_availability_zones.available.names[count.index]}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.gw]
}

# --- Route Tables ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    {
      Name = "${var.cluster_name}-public-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(aws_subnet.private) # One route table per private subnet/AZ for NAT GW routing
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    # Route traffic through the NAT Gateway in the same AZ
    nat_gateway_id = element(aws_nat_gateway.nat[*].id, count.index) # Use element to get corresponding NAT GW
  }

  tags = merge(
    {
      Name = "${var.cluster_name}-private-rt-${data.aws_availability_zones.available.names[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
# --- VPC Flow Logs ---

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.cluster_name}-flow-logs"
  retention_in_days = 365

kms_key_id = var.kms_key_arn_for_logs != null ? var.kms_key_arn_for_logs : null
  tags = merge(
    {
      Name = "${var.cluster_name}-vpc-flow-logs-lg"
    },
    var.tags
  )
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.cluster_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    {
      Name = "${var.cluster_name}-vpc-flow-logs-role"
    },
    var.tags
  )
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_policy" "vpc_flow_logs" {
  name        = "${var.cluster_name}-vpc-flow-logs-policy"
  description = "Allows VPC Flow Logs to publish logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.vpc_flow_logs.arn
      },
    ]
  })

  tags = merge(
    {
      Name = "${var.cluster_name}-vpc-flow-logs-policy"
    },
    var.tags
  )
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "vpc_flow_logs" {
  role       = aws_iam_role.vpc_flow_logs.name
  policy_arn = aws_iam_policy.vpc_flow_logs.arn
}

# VPC Flow Log Resource
resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.cluster_name}-vpc-flow-log"
    },
    var.tags
  )

  # Ensure dependencies are created first
  depends_on = [
    aws_iam_role_policy_attachment.vpc_flow_logs,
    aws_cloudwatch_log_group.vpc_flow_logs
  ]
}