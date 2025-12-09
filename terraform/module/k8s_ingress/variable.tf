variable "ingress_class_name" {
    description = "The ingress class name for the ingress resource"
    type        = string
    default     = "alb"
  
}

variable "controller" {
    description = "The ingress controller for the ingress resource"
    type        = string
    default     = "eks.amazonaws.com/alb"
  
}

variable "ingress_class_name" {
    description = "The name of the ingress class"
    type        = string
    default     = "alb"
  
}

variable "ingress_name" {
    description = "The name of the ingress resource"
    type        = string
    default     = "my-ingress"
  
}

variable "host_name" {
    description = "The host name for the ingress rule"
    type        = string
    default     = null
  
}

variable "path" {
    description = "The path for the ingress rule"
    type        = string
    default     = "/"
  
}

variable "path_type" {
    description = "The path type for the ingress rule"
    type        = string
    default     = "Prefix"
  
}

variable "annotations" {
    description = "Annotations to apply to the ingress resource"
    type        = map(string)
    default     = {
        "alb.ingress.kubernetes.io/scheme" = "internet-facing"
        "alb.ingress.kubernetes.io/target-type" = "ip"
        
    }
  
}

variable "labels" {
  description = "Labels to apply to the deployment"
  type        = map(string)
  default     = {}
}

variable "service_name" {
  description = "The name of the Kubernetes service"
  type        = string
  
}

variable "service_port" {
  description = "The port the service will expose"
  type        = number
}

variable "namespace" {
  description = "The Kubernetes namespace for the deployment"
  type        = string

}