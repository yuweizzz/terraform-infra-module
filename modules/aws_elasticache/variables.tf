variable "replication_group_id" {
  description = "id of elasticache replication group"
  type        = string
}

variable "description" {
  description = "description of elasticache replication group"
  type        = string
}

variable "node_type" {
  description = "node type of elasticache replication group"
  type        = string
}

variable "num_cache_clusters" {
  description = "node number of elasticache replication group"
  type        = number
}

variable "engine" {
  description = "engine of elasticache replication group"
  type        = string
}

variable "engine_version" {
  description = "engine version of elasticache replication group"
  type        = string
}

variable "parameter_group_name" {
  description = "parameter group name of elasticache replication group"
  type        = string
}

variable "port" {
  description = "port number of elasticache replication group"
  type        = number
}

variable "cluster_mode" {
  description = "cluster mode of elasticache replication group"
  type        = string
  validation {
    condition     = contains(["enabled", "disabled", "compatible"], var.cluster_mode)
    error_message = "must be enabled, disabled or compatible"
  }
}

variable "transit_encryption_enabled" {
  description = "transit encryption enabled in elasticache replication group"
  type        = bool
}

variable "auth_token" {
  description = "auth token of elasticache replication group"
  type        = string
}

variable "auth_token_update_strategy" {
  description = "auth token update strategy of elasticache replication group"
  type        = string
  validation {
    condition     = contains(["SET", "ROTATE", "DELETE"], var.auth_token_update_strategy)
    error_message = "must be SET, ROTATE or DELETE"
  }
}

variable "subnet_group" {
  description = "subnet group of elasticache replication group"
  type = object({
    name       = string
    subnet_ids = optional(list(string), [])
  })
}
