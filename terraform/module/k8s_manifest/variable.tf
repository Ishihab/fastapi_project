variable "deployment_name" {
  description = "The name of the Kubernetes deployment"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace for the deployment"
  type        = string
}

variable "replicas" {
  description = "The number of replicas for the deployment"
  type        = number
  default     = 2
}

variable "container_image" {
  description = "The container image for the deployment"
  type        = string
}

variable "container_name" {
  description = "The name of the container in the deployment"
  type        = string
}

variable "container_port" {
  description = "The port the container exposes"
  type        = number
  default     = 80
}

variable "labels" {
  description = "Labels to apply to the deployment"
  type        = map(string)
  default     = {}
}

variable "config_map_name" {
  description = "The name of the ConfigMap to mount as environment variables"
  type        = string
  default     = null
}

variable "secret_name" {
  description = "The name of the Secret to mount as environment variables"
  type        = string
  default     = null
}

variable "service_name" {
  description = "The name of the Kubernetes service"
  type        = string
  
}

variable "service_port" {
  description = "The port the service will expose"
  type        = number
}

variable "target_port" {
  description = "The target port on the pods the service will route to"
  type        = number
  default     = var.container_port
}

variable "protocol" {
  description = "The protocol for the service port"
  type        = string
  default     = "TCP"
}

variable "service_type" {
  description = "The type of Kubernetes service"
  type        = string
  default     = "ClusterIP"
}

