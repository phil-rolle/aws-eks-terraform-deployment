# modules/security/variables.tf
# Input variables for the security module

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "eks-demo-"
}

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster (for tagging)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

