output "ec2_id" {
  value = try(aws_instance.this.id, null)
}

output "ec2_key_id" {
  value = try(aws_key_pair.this[0].id, null)
}
