output "lb_id" {
  value = try(aws_lb.this.id, null)
}
