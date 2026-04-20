variable "bucket_name" {
  description = "name of s3 bucket"
  type        = string
}

variable "allow_public_read" {
  description = "allow public read or not, default is false"
  type        = bool
  default     = false
}

variable "create_queue" {
  description = "create sqs queue or not when create s3 bucket, default is false"
  type        = bool
  default     = false
}
