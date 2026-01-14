locals {
  region             = var.region
  cert_name          = var.cert_name
  import_private_key = var.import_private_key
  import_certificate = var.import_certificate
}

resource "huaweicloud_ccm_certificate_import" "this" {
  name        = local.cert_name
  region      = local.region
  certificate = local.import_certificate
  private_key = local.import_private_key
}
