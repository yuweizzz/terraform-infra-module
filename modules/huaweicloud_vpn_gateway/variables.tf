variable "name" {
  description = "name of vpn gateway"
  type        = string
}

variable "vpc_id" {
  description = "id of vpc"
  type        = string
}

variable "subnet_id" {
  description = "subnet id used by the vpn gateway"
  type        = string
}

variable "local_subnet_cidrs" {
  description = "cidr of local subnet"
  type        = list(string)
}

variable "peer_subnet_cidrs" {
  description = "cidr of peer subnet"
  type        = list(string)
}

variable "eip_bandwidth" {
  description = "bandwidth of vpn gateway eip"
  type        = number
  default     = 10
}

variable "customer_gateways" {
  description = "customer gateways which includes ip address and psk"
  type = list(object({
    name       = string
    ip_address = string
    psk        = string
    eip_index  = number
  }))
}

variable "availability_zones" {
  description = "availability zones of vpn gateway"
  type        = list(string)
}
