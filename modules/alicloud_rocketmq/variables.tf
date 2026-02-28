variable "vpc_id" {
  description = "vpc id of rocketmq instance"
  type        = string
}

variable "vswitch_id" {
  description = "vswitch id of rocketmq instance"
  type        = string
}

variable "instance_name" {
  description = "name of rocketmq instance"
  type        = string
}

variable "instance_type" {
  description = "spec of rocketmq instance"
  type        = string
  default     = "rmq.s2.2xlarge"
}

variable "ip_whitelists" {
  description = "ip whitelists of rocketmq instance"
  type        = list(string)
  default     = []
}
