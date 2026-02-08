variable "name" {
  description = "name of load balancer"
  type        = string
}

variable "vpc_id" {
  description = "vpc id of load balancer"
  type        = string
}

variable "type" {
  description = "type of load balancer"
  type        = string
  validation {
    condition     = contains(["application", "network"], var.type)
    error_message = "must be application or network"
  }
}

variable "subnet_ids" {
  description = "subnet ids of load balancer"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "security group ids of load balancer"
  type        = list(string)
  default     = []
}

variable "net_rules" {
  description = "listener rules of network load balancer"
  type = list(object({
    port              = number
    protocol          = string
    target_group_name = string
  }))
  default = []
}

variable "app_rules" {
  description = "listener rules of application load balancer"
  type = list(object({
    port                     = number
    protocol                 = string
    http_redirect_https_port = optional(number)
    default_cert             = optional(string)
    extra_certs              = optional(list(string), [])
    ssl_policy               = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    rules = list(object({
      host_name         = string
      target_group_name = string
      priority          = number
    }))
  }))
  default = []
}

variable "target_groups" {
  description = "target groups of load balancer"
  type = list(object({
    group_name = string
    protocol   = string
    port       = number
    instances = list(object({
      instance_id = string
      port        = number
    }))
  }))
  default = []
}
