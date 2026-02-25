variable "instance_name" {
  description = "name of ecs instance"
  type        = string
}

variable "instance_type" {
  description = "type of ecs instance / flavor id"
  type        = string
}

variable "image_id" {
  description = "image id of ecs instance, use debian12 as default value"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "subnet id of ecs instance"
  type        = string
}

variable "admin_pass" {
  description = "admin password of ecs instance"
  type        = string
  sensitive   = true
}

variable "security_groups" {
  description = "security groups of ecs instance"
  type        = list(string)
  default     = []
}

variable "root_volume_size" {
  description = "root volume size of ecs instance"
  type        = number
}
