variable "name" {
  description = "name of elb"
  type        = string
}

variable "server_groups" {
  description = "server groups for elb"
  type = list(object({
    name = string
    members = list(object({
      server_id = string
      port      = string
      weight    = optional(number, 1)
    }))
  }))
  default = []
}

variable "acl_groups" {
  description = "ip groups for acl"
  type = list(object({
    name    = string
    entries = list(string)
  }))
  default = []
}

variable "certs" {
  description = "certs of elb"
  type = list(object({
    name          = string
    region        = string
    cert_ref_id   = string
    cert_ref_name = string
  }))
  default = []
}

variable "listeners" {
  description = "listeners of elb"
  type = list(
    object({
      name          = string
      description   = optional(string)
      protocol      = string
      frontend_port = number
      backend_port  = optional(number)
      forward_port  = optional(number)
      default_cert  = optional(string)
      acl_status    = optional(string, "off")
      acl_type      = optional(string)
      acl_groups    = optional(list(string))
    })
  )
}

variable "domain_extensions" {
  description = "domain extensions of elb listener"
  type = list(object({
    cert_name     = string
    domain        = string
    listener_name = string
  }))
  default = []
}

variable "rules" {
  description = "rules of elb"
  type = list(object({
    name              = string
    domain            = string
    listener_name     = string
    server_group_name = string
  }))
}
