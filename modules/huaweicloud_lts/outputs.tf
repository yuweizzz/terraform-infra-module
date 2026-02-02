output "log_group_id" {
  value = try(huaweicloud_lts_group.this.id, null)
}
