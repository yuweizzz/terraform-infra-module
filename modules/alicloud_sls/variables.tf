variable "project_name" {
  description = "name of log project"
  type        = string
}

variable "description" {
  description = "description of log project"
  type        = string
  default     = null
}

variable "logstores" {
  description = "logstores of log project"
  type = list(object({
    name             = string
    retention_period = optional(number, 90)
  }))
  default = []
}

variable "machine_groups" {
  description = "machine groups of log project"
  type = list(object({
    name     = string
    ip_lists = list(string)
  }))
  default = []
}

variable "logtail_configs" {
  description = "logtail configs of log project"
  type = list(object({
    config_name        = string
    logstore_name      = string
    machine_group_name = string
    log_path           = string
    file_pattern       = string
  }))
  default = []
}
