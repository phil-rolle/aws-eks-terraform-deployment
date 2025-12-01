# main.tf
# Root module for EKS deployment
# This root module orchestrates the core infrastructure components by
# leveraging separate reusable modules for IAM, VPC, Security Groups, and EKS.

# Configure AWS provider
provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# Data source to get EKS cluster details
data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

# Data source to get EKS cluster authentication
data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

# Configure Kubernetes provider (will be configured after cluster is created)
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# IAM module to create roles needed for EKS cluster and nodes
module "iam" {
  source      = "./modules/iam"
  name_prefix = var.name_prefix
  tags        = var.tags
}

# VPC module to create networking resources (VPC, subnets, routing)
module "vpc" {
  source               = "./modules/vpc"
  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

# Security module to create Security Groups linked to the VPC
module "security" {
  source       = "./modules/security"
  name_prefix  = var.name_prefix
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
  tags         = var.tags
}

# EKS module to define the cluster, node group, and add-ons
module "eks" {
  source = "./modules/eks"

  cluster_name              = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  cluster_role_arn          = module.iam.eks_cluster_role_arn
  node_role_arn             = module.iam.eks_nodes_role_arn
  subnet_ids                = module.vpc.private_subnet_ids
  cluster_security_group_id = module.security.eks_cluster_sg_id
  node_desired_size         = var.node_desired_size
  node_min_size             = var.node_min_size
  node_max_size             = var.node_max_size
  node_instance_type        = var.node_instance_type
  node_capacity_type        = var.node_capacity_type
  enabled_cluster_log_types = var.enabled_cluster_log_types
  log_retention_days        = var.log_retention_days
  public_access_cidrs       = var.public_access_cidrs
  tags                      = var.tags

  depends_on = [
    module.vpc,
    module.security,
    module.iam
  ]
}

# Kubernetes namespace for the application
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_namespace
    labels = {
      name = var.app_namespace
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }

  depends_on = [module.eks]
}

# Kubernetes deployment for nginx (YAML approach - default)
resource "kubernetes_deployment" "nginx" {
  count = var.deploy_with_yaml ? 1 : 0

  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = var.app_name
          image = var.app_image

          port {
            container_port = var.app_port
          }

          resources {
            requests = {
              cpu    = var.app_cpu_request
              memory = var.app_memory_request
            }
            limits = {
              cpu    = var.app_cpu_limit
              memory = var.app_memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = var.app_port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.app_port
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }

  depends_on = [module.eks, kubernetes_namespace.app]
}

# Kubernetes service for nginx (LoadBalancer type)
resource "kubernetes_service" "nginx" {
  count = var.deploy_with_yaml ? 1 : 0

  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = var.app_name
    }
    annotations = {
      # Ensure LoadBalancer is created in public subnets
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = var.app_name
    }

    port {
      port        = 80
      target_port = var.app_port
      protocol    = "TCP"
    }
  }

  depends_on = [kubernetes_deployment.nginx]
}

