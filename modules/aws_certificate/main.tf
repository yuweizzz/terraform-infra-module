locals {
  import_private_key                = var.import_private_key
  import_certificate_body           = var.import_certificate_body
  import_certificate_chain          = var.import_certificate_chain
  request_domain_name               = var.request_domain_name
  request_subject_alternative_names = var.request_subject_alternative_names
  request_dns_provider              = var.request_dns_provider
  domain_validation = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if dvo.domain_name == local.request_domain_name
  }
}

resource "aws_acm_certificate" "this" {
  private_key       = local.import_private_key
  certificate_body  = local.import_certificate_body
  certificate_chain = local.import_certificate_chain

  domain_name               = local.request_domain_name
  validation_method         = local.request_domain_name != null ? "DNS" : null
  subject_alternative_names = length(local.request_subject_alternative_names) > 0 ? local.request_subject_alternative_names : null
  lifecycle {
    create_before_destroy = true
  }
}

data "cloudflare_zone" "selected" {
  count = local.request_dns_provider == "cloudflare" && local.request_domain_name != null ? 1 : 0

  filter = {
    name = local.request_domain_name
  }
}

resource "cloudflare_dns_record" "this" {
  count = local.request_dns_provider == "cloudflare" && local.request_domain_name != null ? 1 : 0

  zone_id = data.cloudflare_zone.selected[0].zone_id
  name    = local.domain_validation[local.request_domain_name].name
  ttl     = 600
  type    = local.domain_validation[local.request_domain_name].type
  content = local.domain_validation[local.request_domain_name].record
  proxied = false
}

resource "aws_acm_certificate_validation" "this" {
  count = local.request_dns_provider == "cloudflare" && local.request_domain_name != null ? 1 : 0

  certificate_arn = aws_acm_certificate.this.arn
}
