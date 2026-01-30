variable "vpc_id" {
  description = "vpc id of elb"
  type        = string
}

variable "name" {
  description = "name of elb"
  type        = string
}

variable "bandwidth" {
  description = "eip bandwidth of elb"
  type        = string
}

variable "subnet_id" {
  description = "subnet id which elb located"
  type        = string
}

variable "backend_subnets" {
  description = "allowed backend subnet for elb"
  type        = list(string)
}

variable "ip_groups" {
  description = "ip groups for access control"
  type = list(
    object({
      name = string
      ip_lists = list(
        object({
          ip          = string
          description = optional(string)
        })
      )
    })
  )
  default = []
}

variable "listeners" {
  description = "listeners of elb"
  type = list(
    object({
      name          = string
      protocol      = string
      port          = number
      cert_id       = optional(string)
      access_policy = optional(string)
      ip_group_name = optional(string)
    })
  )
}

variable "backend_pools" {
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

variable "policys" {
  description = "policys and rules of elb"
  type = list(
    object({
      name                   = string
      action                 = string
      position               = number
      listener_port          = number
      redirect_pool_name     = optional(string)
      redirect_listener_port = optional(string)
      rules = optional(
        list(
          object({
            type            = string
            compare_type    = string
            condition_value = string
          })
        ), []
      )
    })
  )
}
