variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "assign_ipv6" {
  description = "Assign an IPv6 CIDR block to the VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Tags to apply to the VPC"
  type        = map(string)
  default     = {
    Name = "my-vpc"
    Environment = "dev"
  }
}


