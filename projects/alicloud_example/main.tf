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

module "alicloud_kvstore" {
  source = "../../modules/alicloud_kvstore"

  instance_name = "redis"
  vswitch_id    = "?"
  password      = file("${path.module}/secrets/kvstore_passwd")

  security_ips = [module.alicloud_ecs.private_ip]
}
