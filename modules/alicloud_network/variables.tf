variable "vpc_name" {
  description = "name of vpc"
  type        = string
}

variable "vpc_cidr_block" {
  description = "cidr block of vpc"
  type        = string
}

variable "vswitches" {
  description = "list of vpc vswitches"
  type = list(object({
    name       = string
    cidr_block = string
    zone_id    = string
  }))
  default = []
}

variable "nat_gateway_name" {
  description = "name of nat gateway"
  type        = string
}

variable "nat_gateway_vswitch_name" {
  description = "vswitch name of nat gateway"
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
    vswitch_name = string
    eip_name     = string
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

# type: ingress, egress
# ip_protocol: tcp, udp, icmp, icmpv6, gre, all
# policy: accept, drop
variable "security_groups" {
  description = "security groups of vpc"
  type = list(object({
    name        = string
    description = optional(string)
    ingress_rules = optional(list(object({
      cidr_ip     = string
      ip_protocol = optional(string, "all")
      port_range  = optional(string, "-1/-1")
      policy      = optional(string, "accept")
      priority    = optional(number, 1)
    })), [])
    egress_rules = optional(list(object({
      cidr_ip     = string
      ip_protocol = optional(string, "all")
      port_range  = optional(string, "-1/-1")
      policy      = optional(string, "accept")
      priority    = optional(number, 1)
    })), [])
  }))
  default = []
}
