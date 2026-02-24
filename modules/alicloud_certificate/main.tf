locals {
  cert_name          = var.cert_name
  import_private_key = var.import_private_key
  import_certificate = var.import_certificate
}

resource "alicloud_ssl_certificates_service_certificate" "this" {
  certificate_name = local.cert_name
  cert             = local.import_certificate
  key              = local.import_private_key
}
