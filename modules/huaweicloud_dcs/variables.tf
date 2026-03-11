variable "name" {
  description = "name of dcs instance"
  type        = string
}

variable "flavor_id" {
  description = "type of dcs instance / flavor id"
  type        = string
}

variable "vpc_id" {
  description = "vpc id of dcs instance"
  type        = string
}

variable "subnet_id" {
  description = "subnet id of dcs instance"
  type        = string
}

variable "password" {
  description = "password of dcs instance"
  type        = string
  sensitive   = true
}

variable "capacity" {
  description = "capacity of dcs instance"
  type        = number
}

variable "whitelist" {
  description = "ip whitelist of dcs instance"
  type = object({
    group_name = string
    ip_address = list(string)
  })
}

variable "availability_zones" {
  description = "availability zones of dcs instance"
  type        = list(string)
}
