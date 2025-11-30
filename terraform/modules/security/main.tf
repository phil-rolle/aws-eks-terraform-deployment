# modules/security/main.tf
# This module sets up security groups for the EKS cluster and node groups.

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.name_prefix}eks-cluster-"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  # Allow inbound traffic from nodes
  ingress {
    description = "Allow inbound traffic from nodes"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}eks-cluster-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for EKS Node Group
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.name_prefix}eks-nodes-"
  description = "Security group for EKS node group"
  vpc_id      = var.vpc_id

  # Allow inbound traffic from cluster
  ingress {
    description     = "Allow inbound traffic from EKS cluster"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  # Allow node-to-node communication
  ingress {
    description = "Allow node-to-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    self        = true
  }

  # Allow inbound traffic from ALB/load balancer (for LoadBalancer service type)
  ingress {
    description = "Allow inbound traffic from load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound traffic from load balancer (HTTPS)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.name_prefix}eks-nodes-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

