output "rds_id" {
  value = try(huaweicloud_rds_instance.this.id, null)
}
