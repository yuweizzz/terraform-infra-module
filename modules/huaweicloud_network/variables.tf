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
}

variable "nat_gateway_snat_rules" {
  description = "snat rules of nat gateway"
  type = list(object({
    subnet_name = string
    eip_name    = string
  }))
}

variable "security_groups" {
  description = "security groups of vpc"
  type        = any
}
