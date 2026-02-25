variable "vpc_name" {
  description = "name of vpc"
  type        = string
}

variable "vpc_cidr_block" {
  description = "cidr block of vpc"
  type        = string
}

variable "vpc_subnets" {
  description = "list of vpc subnets"
  type = list(object({
    name       = string
    cidr       = string
    gateway_ip = string
  }))
  default = []
}

variable "nat_gateway_subnet_name" {
  description = "subnet name of nat gateway"
  type        = string
}

variable "nat_gateway_spec" {
  description = "spec of nat gateway"
  type        = string
}

variable "nat_gateway_eips" {
  description = "eips of nat gateway"
  type = list(object({
    eip_name      = string
    eip_bandwidth = number
  }))
  default = []
}

variable "nat_gateway_snat_rules" {
  description = "snat rules of nat gateway"
  type = list(object({
    subnet_name = string
    eip_name    = string
  }))
  default = []
}

variable "nat_gateway_dnat_rules" {
  description = "dnat rules of nat gateway"
  type = list(object({
    ecs                   = any
    eip_name              = string
    protocol              = string
    internal_service_port = number
    external_service_port = number
  }))
  default = []
}

variable "security_groups" {
  description = "security groups of vpc"
  type = list(object({
    name                 = string
    delete_default_rules = optional(bool, false)
    ingress_rules = optional(list(object({
      action      = string
      cidr_ipv4   = string
      ports       = optional(string)
      ip_protocol = optional(string)
    })), [])
    egress_rules = optional(list(object({
      action      = string
      cidr_ipv4   = string
      ports       = optional(string)
      ip_protocol = optional(string)
    })), [])
  }))
  default = []
}
