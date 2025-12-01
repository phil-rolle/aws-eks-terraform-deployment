# modules/vpc/main.tf
# This module sets up the VPC, subnets (public and private), Internet Gateway, NAT Gateway, and routing for the EKS infrastructure.

# Get available availability zones dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

# Define the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}vpc"
    }
  )
}

# Set up DHCP options for the VPC
resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}dhcp-options"
    }
  )
}

# Associate the DHCP options with the VPC
resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

# Create public subnets in multiple availability zones
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}public-subnet-${substr(data.aws_availability_zones.available.names[count.index], -1, 1)}"
      Type = "public"
    }
  )
}

# Create private subnets in multiple availability zones
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name                              = "${var.name_prefix}private-subnet-${substr(data.aws_availability_zones.available.names[count.index], -1, 1)}"
      Type                              = "private"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# Create Internet Gateway for public subnet internet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}internet-gateway"
    }
  )
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}nat-eip"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Create NAT Gateway in first public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}nat-gateway"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}public-route-table"
    }
  )
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}private-route-table"
    }
  )
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

