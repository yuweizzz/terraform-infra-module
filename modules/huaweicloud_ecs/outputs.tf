output "ecs_id" {
  value = try(huaweicloud_compute_instance.this.id, null)
}
