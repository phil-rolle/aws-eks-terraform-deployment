# modules/security/outputs.tf
# Outputs for the security module

output "eks_cluster_sg_id" {
  description = "Security group ID for EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_sg_id" {
  description = "Security group ID for EKS node group"
  value       = aws_security_group.eks_nodes.id
}

