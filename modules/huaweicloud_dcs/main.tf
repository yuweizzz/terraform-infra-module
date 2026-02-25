locals {
  dcs_name      = var.dcs_name
  dcs_flavor_id = var.dcs_flavor_id
  dcs_vpc_id    = var.dcs_vpc_id
  dcs_subnet_id = var.dcs_subnet_id
  dcs_password  = var.dcs_password
  dcs_capacity  = var.dcs_capacity
  dcs_whitelist = var.dcs_whitelist
}

data "huaweicloud_availability_zones" "this" {}

resource "huaweicloud_dcs_instance" "this" {
  name           = local.dcs_name
  engine         = "Redis"
  engine_version = "7.0"
  capacity       = local.dcs_capacity
  flavor         = local.dcs_flavor_id
  password       = local.dcs_password
  vpc_id         = local.dcs_vpc_id
  subnet_id      = local.dcs_subnet_id
  availability_zones = [
    data.huaweicloud_availability_zones.this.names[0]
  ]

  whitelists {
    group_name = local.dcs_whitelist.group_name
    ip_address = local.dcs_whitelist.ip_address
  }

  charging_mode = "prePaid"
  period_unit   = "month"
  period        = 1
  auto_renew    = "true"
}
