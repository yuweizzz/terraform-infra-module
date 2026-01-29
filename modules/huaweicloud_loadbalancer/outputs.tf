output "lb_id" {
  value = try(huaweicloud_elb_loadbalancer.this.id, null)
}
