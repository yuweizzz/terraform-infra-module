locals {
  instance_name    = var.instance_name
  instance_type    = var.instance_type
  image_id         = var.image_id
  vswitch_id       = var.vswitch_id
  root_volume_size = var.root_volume_size
  admin_pass       = var.admin_pass
  security_groups  = var.security_groups
}

data "alicloud_images" "debian" {
  owners     = "system"
  name_regex = "^debian_13_3_x64"
}

resource "alicloud_instance" "this" {
  instance_name   = local.instance_name
  vswitch_id      = local.vswitch_id
  instance_type   = local.instance_type
  image_id        = local.image_id == null ? data.alicloud_images.debian.images.0.id : local.image_id
  host_name       = local.instance_name
  password        = local.admin_pass
  security_groups = local.security_groups

  system_disk_size              = local.root_volume_size
  system_disk_category          = "cloud_essd"
  system_disk_performance_level = "PL0"

  internet_max_bandwidth_out = 0

  instance_charge_type = "PrePaid"
  period               = 1
  auto_renew_period    = 1
  renewal_status       = "AutoRenewal"
}
