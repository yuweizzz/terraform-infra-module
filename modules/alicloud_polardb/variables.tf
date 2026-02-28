variable "cluster_name" {
  description = "name of polardb cluster"
  type        = string
}

variable "db_node_class" {
  description = "db node class of polardb cluster"
  type        = string
  default     = "polar.mysql.g2.medium"
}

variable "db_node_count" {
  description = "db node count of polardb cluster"
  type        = number
  default     = 2
}

variable "vswitch_id" {
  description = "vswitch id of polardb cluster"
  type        = string
}

variable "standby_az" {
  description = "standby available zone of polardb cluster"
  type        = string
}

variable "security_ips" {
  description = "security ips of polardb cluster"
  type        = list(string)
  default     = []
}
