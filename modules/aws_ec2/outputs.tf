output "ec2_id" {
  value = try(aws_instance.this.id, null)
}
