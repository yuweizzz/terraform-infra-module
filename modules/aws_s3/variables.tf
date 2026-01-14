variable "bucket_name" {
  description = "name of s3 bucket"
  type        = string
}

variable "allow_public_read" {
  description = "allow public read or not, default is false"
  type        = bool
  default     = false
}
