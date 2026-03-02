output "vpc_id" {
  value = try(alicloud_vpc.this.id, null)
}

output "vswitch_ids" {
  value = try({ for k, v in alicloud_vswitch.this : k => v.id }, null)
}

output "security_group_ids" {
  value = try({ for k, v in alicloud_security_group.this : k => v.id }, null)
}
