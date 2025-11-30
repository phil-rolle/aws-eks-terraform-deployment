# modules/iam/outputs.tf
# Outputs for the IAM module

output "eks_cluster_role_arn" {
  description = "ARN of the IAM role for EKS cluster"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_nodes_role_arn" {
  description = "ARN of the IAM role for EKS node group"
  value       = aws_iam_role.eks_nodes.arn
}

output "eks_cluster_role_name" {
  description = "Name of the IAM role for EKS cluster"
  value       = aws_iam_role.eks_cluster.name
}

output "eks_nodes_role_name" {
  description = "Name of the IAM role for EKS node group"
  value       = aws_iam_role.eks_nodes.name
}

