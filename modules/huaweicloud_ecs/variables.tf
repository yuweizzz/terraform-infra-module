variable "ecs_instance_name" {
  description = "name of ecs instance"
  type        = string
}

variable "ecs_instance_type" {
  description = "type of ecs instance / flavor id"
  type        = string
}

variable "ecs_image_id" {
  description = "image id of ecs instance, use debian12 as default value"
  type        = string
  default     = null
}

variable "ecs_subnet_id" {
  description = "subnet id of ecs instance"
  type        = string
}

variable "ecs_admin_pass" {
  description = "admin password of ecs instance"
  type        = string
  sensitive   = true
}

variable "ecs_security_groups" {
  description = "security groups of ecs instance"
  type        = list(string)
  default     = []
}

variable "ecs_root_volume_size" {
  description = "root volume size of ecs instance"
  type        = number
}
