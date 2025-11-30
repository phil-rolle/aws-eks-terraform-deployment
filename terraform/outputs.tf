# outputs.tf
# Outputs from root module for EKS infrastructure

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "eks_node_group_arn" {
  description = "ARN of the EKS node group"
  value       = module.eks.node_group_arn
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  value       = module.security.eks_cluster_sg_id
}

output "eks_nodes_security_group_id" {
  description = "Security group ID for EKS nodes"
  value       = module.security.eks_nodes_sg_id
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "nginx_service_url" {
  description = "URL to access the nginx service (if deployed via Terraform)"
  value       = var.deploy_with_yaml && length(kubernetes_service.nginx) > 0 ? "http://${kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].hostname}" : "Deploy application manually or set deploy_with_yaml = true"
}

