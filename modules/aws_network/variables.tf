variable "vpc_name" {
  description = "name of vpc"
  type        = string
}

variable "vpc_cidr_block" {
  description = "cidr block of vpc"
  type        = string
}

variable "vpc_private_subnets" {
  description = "map of availability zone and private subnet"
  type        = map(string)
}

variable "vpc_public_subnets" {
  description = "map of availability zone and public subnet"
  type        = map(string)
}

variable "security_groups" {
  description = "list of security groups"
  type        = any
}
