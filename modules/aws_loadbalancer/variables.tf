variable "lb_vpc_id" {
  description = "vpc id of load balancer"
  type        = string
}

variable "lb_name" {
  description = "name of load balancer"
  type        = string
}

variable "lb_type" {
  description = "type of load balancer"
  type        = string
  validation {
    condition     = contains(["application", "network"], var.lb_type)
    error_message = "must be application or network"
  }
}

variable "lb_subnets" {
  description = "subnet ids of load balancer"
  type        = list(string)
  default     = []
}

variable "lb_security_groups" {
  description = "security group ids of load balancer"
  type        = list(string)
  default     = []
}

variable "lb_net_rules" {
  description = "listener rules of network load balancer"
  type        = any
  default     = []
}

variable "lb_app_rules" {
  description = "listener rules of application load balancer"
  type        = any
  default     = []
}

variable "lb_target_groups" {
  description = "target groups of load balancer"
  type        = any
  default     = []
}
