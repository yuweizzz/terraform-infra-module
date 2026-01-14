output "cert_id" {
  value = try(huaweicloud_ccm_certificate_import.this.id, null)
}
