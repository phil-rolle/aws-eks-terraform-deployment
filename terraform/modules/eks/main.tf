# modules/eks/main.tf
# This module deploys an EKS cluster with managed node group and CloudWatch logging.

# CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [var.cluster_security_group_id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.public_access_cidrs
  }

  # Enable CloudWatch logging
  enabled_cluster_log_types = var.enabled_cluster_log_types

  # Ensure CloudWatch log group exists before cluster creation
  depends_on = [
    aws_cloudwatch_log_group.eks_cluster
  ]

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  # Scaling configuration
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  # Instance configuration
  instance_types = [var.node_instance_type]
  capacity_type  = var.node_capacity_type

  # Update configuration
  update_config {
    max_unavailable = 1
  }

  # Remote access (optional - commented out for security)
  # remote_access {
  #   ec2_ssh_key = var.ssh_key_name
  # }

  # Ensure cluster is ready before creating node group
  depends_on = [
    aws_eks_cluster.main,
    var.node_role_arn
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-node-group"
    }
  )

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# EKS Add-ons (VPC CNI, CoreDNS, kube-proxy are installed by default)
# Optionally add other add-ons here if needed

