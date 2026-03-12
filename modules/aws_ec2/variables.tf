variable "instance_name" {
  description = "name of ec2 instance"
  type        = string
}

variable "instance_type" {
  description = "type of ec2 instance"
  type        = string
}

variable "ami_id" {
  description = "ami id of ec2 instance"
  type        = string
}

variable "associate_public_ip_address" {
  description = "associate public ip address to ec2 instance, use false as default value"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "subnet id of ec2 instance"
  type        = string
}

variable "security_groups" {
  description = "security groups of ec2 instance"
  type        = list(string)
  default     = []
}

variable "root_volume_size" {
  description = "root volume size of ec2 instance"
  type        = string
}

variable "specified_key_id" {
  description = "use existing ec2 key pair in ec2 instance"
  type        = string
  default     = null
}

variable "import_key_name" {
  description = "create ec2 key pair and apply in ec2 instance, the name of new key pair, use with 'import_key_content' variable"
  type        = string
  default     = null
}

variable "import_key_content" {
  description = "create ec2 key pair and apply in ec2 instance, the content of new key pair, use with 'import_key' variable"
  type        = string
  default     = null
}
