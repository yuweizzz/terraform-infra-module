provider "alicloud" {
  region = local.region
}

locals {
  region = "ap-southeast-1"
}

module "alicloud_certificate" {
  source = "../../modules/alicloud_certificate"

  cert_name          = "host_com"
  import_certificate = file("${path.module}/secrets/crt.pem")
  import_private_key = file("${path.module}/secrets/key.pem")
}
