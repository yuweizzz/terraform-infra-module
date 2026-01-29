variable "lb_vpc_id" {
  description = "vpc id of elb"
  type        = string
}

variable "lb_name" {
  description = "name of elb"
  type        = string
}

variable "lb_bandwidth" {
  description = "vip bandwidth of elb"
  type        = string
}

variable "lb_subnet_id" {
  description = "subnet which elb located"
  type        = string
}

variable "lb_backend_subnets" {
  description = "allowed backend subnet for elb"
  type        = list(string)
}

variable "lb_listeners" {
  description = "listeners of elb"
  type = list(
    object({
      name     = string
      protocol = string
      port     = number
      cert_id  = optional(string)
    })
  )
}

variable "lb_backend_pools" {
  description = "backend pool of elb"
  type = list(
    object({
      name     = string
      protocol = optional(string, "HTTP")
      type     = optional(string, "instance")
      method   = optional(string, "ROUND_ROBIN")
      members = list(
        object({
          subnet_id = string
          address   = string
          port      = number
        })
      )
    })
  )
}

variable "lb_policys" {
  description = "policys and rules of elb"
  type = list(
    object({
      name                   = string
      action                 = string
      position               = number
      listener_port          = number
      redirect_pool_name     = optional(string)
      redirect_listener_port = optional(string)
      rules = list(
        object({
          type            = string
          compare_type    = string
          condition_value = string
        })
      )
    })
  )
}
