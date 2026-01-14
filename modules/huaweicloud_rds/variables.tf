variable "rds_name" {
  description = "name of rds instance"
  type        = string
}

variable "rds_flavor_id" {
  description = "type of rds instance / flavor id"
  type        = string
}

variable "rds_vpc_id" {
  description = "vpc id of rds instance"
  type        = string
}

variable "rds_subnet_id" {
  description = "subnet id of rds instance"
  type        = string
}

variable "rds_security_group" {
  description = "security group id of rds instance"
  type        = string
}

variable "rds_password" {
  description = "password of rds instance"
  type        = string
  sensitive   = true
}

variable "rds_storage_size" {
  description = "storage size of rds instance"
  type        = number
}

variable "rds_timezone" {
  description = "timezone of rds instance, default is UTC+08:00"
  type        = string
  default     = "UTC+08:00"
}
