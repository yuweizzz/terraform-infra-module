output "ecs_id" {
  value = try(huaweicloud_compute_instance.this.id, null)
}

output "access_ip_v4" {
  value = try(huaweicloud_compute_instance.this.access_ip_v4, null)
}

output "network" {
  value = try(huaweicloud_compute_instance.this.network, null)
}
