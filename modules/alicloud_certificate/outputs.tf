output "cert_id" {
  value = try(alicloud_ssl_certificates_service_certificate.this.id, null)
}

output "cert_name" {
  value = try(alicloud_ssl_certificates_service_certificate.this.certificate_name, null)
}
