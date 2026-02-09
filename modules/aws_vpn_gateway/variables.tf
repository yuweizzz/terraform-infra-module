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

variable "local_subnet_cidr" {
  description = "local subnet cidr of vpn gateway"
  type        = string
}

variable "peer_subnet_cidr" {
  description = "remote subnet cidr of vpn gateway"
  type        = string
}

variable "customer_gateway_name" {
  description = "name of customer gateway"
  type        = string
}

variable "customer_gateway_ip_address" {
  description = "ip address of customer gateway"
  type        = string
}
