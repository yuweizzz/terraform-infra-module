output "dcs_id" {
  value = try(huaweicloud_dcs_instance.this.id, null)
}
