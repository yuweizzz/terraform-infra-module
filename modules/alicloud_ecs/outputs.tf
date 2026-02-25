output "ecs_id" {
  value = try(alicloud_instance.this.id, null)
}

output "private_ip" {
  value = try(alicloud_instance.this.private_ip, null)
}
