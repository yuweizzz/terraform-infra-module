output "arn" {
  value = local.import_private_key != null && local.import_certificate_body != null ? aws_acm_certificate.this.arn : aws_acm_certificate_validation.this[0].certificate_arn
}
