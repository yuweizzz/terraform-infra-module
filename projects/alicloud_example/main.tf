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

module "alicloud_ecs" {
  source = "../../modules/alicloud_ecs"

  instance_name    = "instance-1"
  instance_type    = "ecs.c9a.large"
  vswitch_id       = "?"
  admin_pass       = file("${path.module}/secrets/ecs_passwd")
  root_volume_size = 50
  security_groups  = ["?"]
}
