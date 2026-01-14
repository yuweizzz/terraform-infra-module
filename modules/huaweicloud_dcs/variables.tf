variable "dcs_name" {
  description = "name of dcs instance"
  type        = string
}

variable "dcs_flavor_id" {
  description = "type of dcs instance / flavor id"
  type        = string
}

variable "dcs_vpc_id" {
  description = "vpc id of dcs instance"
  type        = string
}

variable "dcs_subnet_id" {
  description = "subnet id of dcs instance"
  type        = string
}

variable "dcs_password" {
  description = "password of dcs instance"
  type        = string
  sensitive   = true
}

variable "dcs_capacity" {
  description = "capacity of dcs instance"
  type        = number
}

variable "dcs_whitelist" {
  description = "ip whitelist of dcs instance"
  type = object({
    group_name = string
    ip_address = list(string)
  })
}
