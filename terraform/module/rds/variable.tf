variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  default     = "my-rds-instance"
  
}

variable "db_allocated_storage" {
  description = "The allocated storage in GB for the RDS instance"
  type        = number
  default     = 8
  
}

variable "db_engine" {
  description = "The database engine for the RDS instance"
  type        = string
  default     = "mysql"
  
}

variable "db_engine_version" {
  description = "The database engine version for the RDS instance"
  type        = string
  default     = "8.0"
  
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
  
}

variable "db_name" {
  description = "The name of the initial database to create"
  type        = string
  default     = "mydatabase"
  
}

variable "db_username" {
  description = "The master username for the RDS instance"
  type        = string
  default     = "admin"
  
}

variable "db_security_group_ids" {
  description = "The security group IDs to associate with the RDS instance"
  type        = list(string)
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the RDS instance"         
    type        = bool
    default     = true
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}

variable "db_backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
  
}

variable "db_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur"
  type        = string
  default     = "sun:05:00-sun:06:00"
  
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is a Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "db_monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected"
  type        = number
  default     = 60
}


variable "db_tags" {
  description = "Tags to apply to the RDS instance"
  type        = map(string)
  default     = {
    Name = "my-rds-instance"
    Environment = "dev"
  }
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group"
  type        = string
  default     = "custom-db-parameter-group"
  
}