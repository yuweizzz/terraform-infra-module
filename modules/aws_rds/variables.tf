variable "cluster_identifier" {
  description = "identifier of rds cluster"
  type        = string
}

variable "engine" {
  description = "engine of rds cluster"
  type        = string
  validation {
    condition     = contains(["aurora-mysql"], var.engine)
    error_message = "only support aurora-mysql engine for now"
  }
  default = "aurora-mysql"
}

variable "engine_version" {
  description = "engine version of rds cluster"
  type        = string
}

variable "master_username" {
  description = "master username of rds cluster"
  type        = string
}

variable "master_password" {
  description = "master password of rds cluster"
  type        = string
  sensitive   = true
}

variable "subnet_group" {
  description = "subnet group of rds cluster"
  type = object({
    name       = string
    subnet_ids = optional(list(string), [])
  })
}

variable "cluster_instance_type" {
  description = "cluster instance type of rds cluster"
  type        = string
}

variable "cluster_instance_num" {
  description = "cluster instance number of rds cluster"
  type        = number
}

variable "cluster_instance_prefix" {
  description = "cluster instance prefix name of rds cluster"
  type        = string
  default     = "db"
}

variable "enabled_parameter_group_initialize" {
  description = "enabled parameter group initialize or not"
  type        = bool
  default     = false
}

variable "cluster_parameter_group_name" {
  description = "cluster parameter group name of rds cluster"
  type        = string
  default     = null
}

variable "instance_parameter_group_name" {
  description = "instance parameter group name of rds cluster"
  type        = string
  default     = null
}
