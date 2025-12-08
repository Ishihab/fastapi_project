variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-cluster"
  
}

variable "subnet_ids" {
  description = "The IDs of the subnets for the EKS cluster"
  type        = list(string)
}

