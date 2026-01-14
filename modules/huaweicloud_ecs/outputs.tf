output "ecs_id" {
  value = try(huaweicloud_compute_instance.this.id, null)
}

output "ecs_access_ip_v4" {
  value = try(huaweicloud_compute_instance.this.access_ip_v4, null)
}
