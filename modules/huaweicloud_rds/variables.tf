variable "name" {
  description = "name of rds instance"
  type        = string
}

variable "flavor_id" {
  description = "type of rds instance / flavor id"
  type        = string
}

variable "vpc_id" {
  description = "vpc id of rds instance"
  type        = string
}

variable "subnet_id" {
  description = "subnet id of rds instance"
  type        = string
}

variable "security_group" {
  description = "security group id of rds instance"
  type        = string
}

variable "password" {
  description = "password of rds instance"
  type        = string
  sensitive   = true
}

variable "storage_size" {
  description = "storage size of rds instance"
  type        = number
}

variable "timezone" {
  description = "timezone of rds instance, default is UTC+08:00"
  type        = string
  default     = "UTC+08:00"
}

variable "availability_zones" {
  description = "availability zones of rds instance"
  type        = list(string)
}
