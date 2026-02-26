variable "bucket_name" {
  description = "name of bucket"
  type        = string
}

variable "acl" {
  description = "acl of bucket"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public-read", "public-read-write"], var.acl)
    error_message = "must be private, public-read or public-read-write"
  }
}
