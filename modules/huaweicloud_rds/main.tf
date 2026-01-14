terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.36.0"
    }
  }
}

locals {
  rds_name           = var.rds_name
  rds_flavor_id      = var.rds_flavor_id
  rds_vpc_id         = var.rds_vpc_id
  rds_subnet_id      = var.rds_subnet_id
  rds_security_group = var.rds_security_group
  rds_password       = var.rds_password
  rds_storage_size   = var.rds_storage_size
  rds_timezone       = var.rds_timezone
}

data "huaweicloud_availability_zones" "this" {}

resource "huaweicloud_rds_instance" "this" {
  name              = local.rds_name
  flavor            = local.rds_flavor_id
  vpc_id            = local.rds_vpc_id
  subnet_id         = local.rds_subnet_id
  security_group_id = local.rds_security_group
  availability_zone = [
    data.huaweicloud_availability_zones.this.names[0]
  ]
  time_zone = local.rds_timezone

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
