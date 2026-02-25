locals {
  vswitch_id     = var.vswitch_id
  instance_name  = var.instance_name
  instance_class = var.instance_class
  instance_type  = var.instance_type
  engine_version = var.engine_version
  password       = var.password
  security_ips   = var.security_ips
}

data "alicloud_zones" "available_zones" {
  available_resource_creation = "VSwitch"
}

resource "alicloud_kvstore_instance" "this" {
  db_instance_name  = local.instance_name
  vswitch_id        = local.vswitch_id
  zone_id           = data.alicloud_zones.available_zones.zones.0.id
  secondary_zone_id = data.alicloud_zones.available_zones.zones.1.id

  instance_class = local.instance_class
  instance_type  = local.instance_type
  engine_version = local.engine_version

  password     = local.password
  security_ips = local.security_ips

  payment_type      = "PrePaid"
  period            = "1"
  auto_renew        = true
  auto_renew_period = "1"
}
