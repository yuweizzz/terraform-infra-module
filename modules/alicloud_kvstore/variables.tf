variable "vswitch_id" {
  description = "vswitch id of kvstore instance"
  type        = string
}

variable "instance_name" {
  description = "name of kvstore instance"
  type        = string
}

variable "instance_class" {
  description = "class of kvstore instance"
  type        = string
  default     = "redis.master.mid.default"
}

variable "instance_type" {
  description = "type of kvstore instance"
  type        = string
  default     = "Redis"
}

variable "engine_version" {
  description = "engine version of kvstore instance"
  type        = string
  default     = "5.0"
}

variable "password" {
  description = "password of kvstore instance"
  type        = string
  sensitive   = true
}

variable "security_ips" {
  description = "security ips of kvstore instance"
  type        = list(string)
  default     = []
}
