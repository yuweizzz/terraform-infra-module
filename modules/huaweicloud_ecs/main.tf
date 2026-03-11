locals {
  ecs_name              = var.instance_name
  ecs_flavor_id         = var.instance_type
  ecs_image_id          = var.image_id
  ecs_subnet_id         = var.subnet_id
  ecs_availability_zone = var.availability_zone
  ecs_root_volume_size  = var.root_volume_size
  ecs_admin_pass        = var.admin_pass
  ecs_security_groups   = var.security_groups
}

resource "huaweicloud_compute_instance" "this" {
  name              = local.ecs_name
  admin_pass        = local.ecs_admin_pass
  image_id          = local.ecs_image_id
  flavor_id         = local.ecs_flavor_id
  availability_zone = local.ecs_availability_zone

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
