variable "name" {
  description = "name of log group"
  type        = string
}

variable "ttl_in_days" {
  description = "ttl in days of log group"
  type        = number
  default     = 90
}

variable "log_streams" {
  description = "list of log streams"
  type = list(object({
    name = string
  }))
  default = []
}

variable "host_groups" {
  description = "list of host groups"
  type = list(object({
    name           = string
    host_name_list = optional(list(string), [])
    host_ip_list   = optional(list(string), [])
  }))
  default = []
}

variable "host_accesses" {
  description = "list of host accesses"
  type = list(object({
    name             = string
    stream_name      = string
    host_group_names = list(string)
    log_paths        = list(string)
  }))
  default = []
}
