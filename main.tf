resource "aws_vpc" "medicare" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "medicare-vpc"
    Project     = "MediCare"
    Environment = "production"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.medicare.id
  cidr_block              = cidrsubnet(aws_vpc.medicare.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "medicare-public-${count.index + 1}"
    Project     = "MediCare"
    Environment = "production"
    Tier        = "public"
  }
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.medicare.id
  cidr_block        = cidrsubnet(aws_vpc.medicare.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "medicare-private-${count.index + 1}"
    Project     = "MediCare"
    Environment = "production"
    Tier        = "private"
  }
}

resource "aws_internet_gateway" "medicare" {
  vpc_id = aws_vpc.medicare.id

  tags = {
    Name        = "medicare-igw"
    Project     = "MediCare"
    Environment = "production"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.medicare.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.medicare.id
  }

  tags = {
    Name        = "medicare-public-rt"
    Project     = "MediCare"
    Environment = "production"
  }
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = {
    Name        = "medicare-nat-eip-${count.index + 1}"
    Project     = "MediCare"
    Environment = "production"
  }
}

resource "aws_nat_gateway" "medicare" {
  count = 2

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "medicare-nat-${count.index + 1}"
    Project     = "MediCare"
    Environment = "production"
  }

  depends_on = [aws_internet_gateway.medicare]
}

resource "aws_route_table" "private" {
  count = 2

  vpc_id = aws_vpc.medicare.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.medicare[count.index].id
  }

  tags = {
    Name        = "medicare-private-rt-${count.index + 1}"
    Project     = "MediCare"
    Environment = "production"
  }
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ============================================================
# EKS CLUSTER
# ============================================================

resource "aws_iam_role" "eks_cluster" {
  name = "medicare-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = "MediCare"
    Environment = "production"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_security_group" "eks_cluster" {
  name        = "medicare-eks-cluster-sg"
  description = "Security group for MediCare EKS cluster"
  vpc_id      = aws_vpc.medicare.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "medicare-eks-cluster-sg"
    Project     = "MediCare"
    Environment = "production"
  }
}

resource "aws_eks_cluster" "medicare" {
  name     = "medicare-eks"
  role_arn = aws_iam_role.eks_cluster.arn

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name        = "medicare-eks"
    Project     = "MediCare"
    Environment = "production"
  }
}


# ============================================================
# EKS NODE GROUP
# ============================================================

resource "aws_iam_role" "eks_nodes" {
  name = "medicare-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = "MediCare"
    Environment = "production"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read_only" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "medicare" {
  cluster_name    = aws_eks_cluster.medicare.name
  node_group_name = "medicare-workers"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = aws_subnet.private[*].id

  instance_types = ["t3.small"]

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only
  ]

  tags = {
    Name        = "medicare-eks-worker"
    Project     = "MediCare"
    Environment = "production"
  }
}