# variables.tf
# Input variables for the root module

variable "region" {
  description = "AWS region for the resources"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "eks-demo-"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-demo-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 4
}

variable "node_instance_type" {
  description = "EC2 instance type for the node group"
  type        = string
  default     = "t3.medium"
}

variable "node_capacity_type" {
  description = "Type of capacity for the node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "Node capacity type must be either ON_DEMAND or SPOT."
  }
}

variable "enabled_cluster_log_types" {
  description = "List of log types to enable for the EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the EKS API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "nginx"
}

variable "app_namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "default"
}

variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "nginx:alpine"
}

variable "app_replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "Port on which the application listens"
  type        = number
  default     = 80
}

variable "app_cpu_request" {
  description = "CPU request for the application container"
  type        = string
  default     = "100m"
}

variable "app_memory_request" {
  description = "Memory request for the application container"
  type        = string
  default     = "128Mi"
}

variable "app_cpu_limit" {
  description = "CPU limit for the application container"
  type        = string
  default     = "500m"
}

variable "app_memory_limit" {
  description = "Memory limit for the application container"
  type        = string
  default     = "512Mi"
}

variable "deploy_with_yaml" {
  description = "Whether to deploy the application using Terraform (YAML approach). Set to false to deploy manually with kubectl or Helm"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "eks-demo"
    ManagedBy   = "Terraform"
  }
}

