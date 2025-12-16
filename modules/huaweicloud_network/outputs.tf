output "vpc_id" {
  value = try(huaweicloud_vpc.this.id, null)
}

output "subnet_ids" {
  value = try(
    { for k, v in huaweicloud_vpc_subnet.this : k => v.id },
    null
  )
}
