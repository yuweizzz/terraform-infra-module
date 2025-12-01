variable "ec2_instance_name" {
  description = "name of ec2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "type of ec2 instance"
  type        = string
}

variable "ec2_ami" {
  description = "ami id of ec2 instance, use debian13 as default value"
  type        = string
  default     = ""
}

variable "ec2_associate_public_ip_address" {
  description = "associate public ip address to ec2 instance, use false as default value"
  type        = bool
  default     = false
}

variable "ec2_subnet_id" {
  description = "subnet id of ec2 instance"
  type        = string
}

variable "ec2_security_groups" {
  description = "security groups of ec2 instance"
  type        = list(string)
  default     = []
}

variable "ec2_root_volume_size" {
  description = "root volume size of ec2 instance"
  type        = string
}

variable "ec2_specified_key" {
  description = "use existing ec2 key pair in ec2 instance"
  type        = string
  default     = ""
}

variable "ec2_import_key" {
  description = "create ec2 key pair and apply in ec2 instance, the name of new key pair, use with 'ec2_import_key_content' variable"
  type        = string
  default     = ""
}

variable "ec2_import_key_content" {
  description = "create ec2 key pair and apply in ec2 instance, the content of new key pair, use with 'ec2_import_key' variable"
  type        = string
  default     = ""
}
