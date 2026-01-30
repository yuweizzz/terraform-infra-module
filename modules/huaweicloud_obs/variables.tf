variable "bucket_name" {
  description = "name of bucket"
  type        = string
}

variable "acl" {
  description = "acl of bucket"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public-read", "public-read-write", "log-delivery-write"], var.acl)
    error_message = "must be private, public-read, public-read-write or log-delivery-write"
  }
}

variable "storage_class" {
  description = "storage class of bucket"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "WARM", "COLD"], var.storage_class)
    error_message = "must be STANDARD, WARM or COLD"
  }
}

variable "multi_az" {
  description = "allow use multi zone or not, default is false"
  type        = bool
  default     = false
}

variable "region" {
  description = "region of bucket, if not specified, used the region by the provider."
  type        = string
  default     = null
}
