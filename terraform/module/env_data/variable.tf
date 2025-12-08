variable "config_map_name" {
    description = "The name of the ConfigMap"
    type        = string
    default     = "my-config-map"
  
}

variable "namespace" {
    description = "The namespace for the ConfigMap"
    type        = string
    default     = "default"
  
}

variable "labels" {
    description = "Labels to apply to the ConfigMap"
    type        = map(string)
    default     = {}
  
}

variable "config_map_data" {
    description = "Data to include in the ConfigMap"
    type        = map(string)
    default     = {}
  
}

variable "secret_name" {
    description = "The name of the Secret"
    type        = string
    default     = "my-secret"
  
}

variable "secret_data" {
    description = "Data to include in the Secret"
    type        = map(string)
    default     = {}    
    }

variable "secret_data_revision" {
    description = "Revision data for the Secret"
    type        = number
    default     = 1
}