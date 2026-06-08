variable "name" {
  description = "name of vpn gateway"
  type        = string
}

variable "vpc_id" {
  description = "vpc id of vpn gateway"
  type        = string
}

variable "route_propagation_table_ids" {
  description = "route table id for vpn gateway route propagation"
  type        = list(string)
}

variable "customer_gateways" {
  description = "customer gateway"
  type = list(object({
    name       = string
    ip_address = string
    bgp_asn    = optional(number, 65000)
  }))
  default = []
}

variable "vpn_connections" {
  description = "vpn connection"
  type = list(object({
    name                     = string
    customer_gateway_name    = string
    local_ipv4_network_cidr  = optional(string)
    remote_ipv4_network_cidr = optional(string)
    static_routes_only       = optional(bool, false)
    destination_cidr_block   = optional(list(string), [])
  }))
  default = []
}
