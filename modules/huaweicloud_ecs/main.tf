terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.36.0"
    }
  }
}

locals {
  ecs_name             = var.ecs_instance_name
  ecs_flavor_id        = var.ecs_instance_type
  ecs_image_id         = var.ecs_image_id
  ecs_subnet_id        = var.ecs_subnet_id
  ecs_root_volume_size = var.ecs_root_volume_size
  ecs_admin_pass       = var.ecs_admin_pass
  ecs_security_groups  = var.ecs_security_groups
}

data "huaweicloud_availability_zones" "this" {}

data "huaweicloud_images_image" "this" {
  name = "Debian 12.0.0 64bit"
}

resource "huaweicloud_compute_instance" "this" {
  name              = local.ecs_name
  admin_pass        = local.ecs_admin_pass
  image_id          = try(local.ecs_image_id, data.huaweicloud_images_image.this.id)
  flavor_id         = local.ecs_flavor_id
  availability_zone = data.huaweicloud_availability_zones.this.names[0]

  system_disk_size   = local.ecs_root_volume_size
  security_group_ids = local.ecs_security_groups

  network {
    uuid              = local.ecs_subnet_id
    source_dest_check = false
  }

  charging_mode = "prePaid"
  period_unit   = "month"
  period        = 1
  auto_renew    = "true"
}
