locals {
  dcs_name               = var.name
  dcs_flavor_id          = var.flavor_id
  dcs_vpc_id             = var.vpc_id
  dcs_subnet_id          = var.subnet_id
  dcs_password           = var.password
  dcs_capacity           = var.capacity
  dcs_whitelist          = var.whitelist
  dcs_availability_zones = var.availability_zones
}

resource "huaweicloud_dcs_instance" "this" {
  name               = local.dcs_name
  engine             = "Redis"
  engine_version     = "7.0"
  capacity           = local.dcs_capacity
  flavor             = local.dcs_flavor_id
  password           = local.dcs_password
  vpc_id             = local.dcs_vpc_id
  subnet_id          = local.dcs_subnet_id
  availability_zones = local.dcs_availability_zones

  whitelists {
    group_name = local.dcs_whitelist.group_name
    ip_address = local.dcs_whitelist.ip_address
  }

  charging_mode = "prePaid"
  period_unit   = "month"
  period        = 1
  auto_renew    = "true"
}
