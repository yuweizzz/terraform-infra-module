output "vpc_id" {
  value  = try(aws_vpc.this.id, null)
}

output "default_security_group_id" {
  value = try(data.aws_security_group.selected.id, null)
}

output "security_group_ids" {
  value = try(
    { for k, v in aws_security_group.this : k => v.id },
    null
  )
}

output "private_subnet_ids" {
  value = try(
    { for k, v in aws_subnet.private : k => v.id },
    null
  )
}

output "public_subnet_ids" {
  value = try(
    { for k, v in aws_subnet.public : k => v.id },
    null
  )
}
