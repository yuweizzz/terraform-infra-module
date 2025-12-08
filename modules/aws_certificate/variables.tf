variable "import_private_key" {
  description = "private key to import"
  type        = string
  default     = null
}

variable "import_certificate_body" {
  description = "certificate body to import"
  type        = string
  default     = null
}

variable "import_certificate_chain" {
  description = "certificate chain to import"
  type        = string
  default     = null
}

variable "request_domain_name" {
  description = "domain name to request"
  type        = string
  default     = null
}

variable "request_subject_alternative_names" {
  description = "subject alternative names to request"
  type        = list(string)
  default     = []
}

variable "request_dns_provider" {
  description = "dns provider use to request, only support cloudflare"
  type        = string
  validation {
    condition     = contains(["cloudflare"], var.request_dns_provider)
    error_message = "only support cloudflare as dns provider"
  }
  default = "cloudflare"
}
