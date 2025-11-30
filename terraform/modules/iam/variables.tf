# modules/iam/variables.tf
# Input variables for the IAM module

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "eks-demo-"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

