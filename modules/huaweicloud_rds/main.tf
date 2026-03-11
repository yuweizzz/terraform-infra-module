locals {
  rds_name               = var.name
  rds_flavor_id          = var.flavor_id
  rds_vpc_id             = var.vpc_id
  rds_subnet_id          = var.subnet_id
  rds_security_group     = var.security_group
  rds_password           = var.password
  rds_storage_size       = var.storage_size
  rds_timezone           = var.timezone
  rds_availability_zones = var.availability_zones
}

resource "huaweicloud_rds_instance" "this" {
  name              = local.rds_name
  flavor            = local.rds_flavor_id
  vpc_id            = local.rds_vpc_id
  subnet_id         = local.rds_subnet_id
  security_group_id = local.rds_security_group
  availability_zone = local.rds_availability_zones
  time_zone         = local.rds_timezone

  db {
    type     = "MySQL"
    version  = "8.0"
    password = local.rds_password
  }
  volume {
    type = "CLOUDSSD"
    size = local.rds_storage_size
  }

  charging_mode = "prePaid"
  period_unit   = "month"
  period        = 1
  auto_renew    = "true"
}
