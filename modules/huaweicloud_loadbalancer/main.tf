locals {
  lb_name            = var.lb_name
  lb_bandwidth       = var.lb_bandwidth
  lb_vpc_id          = var.lb_vpc_id
  lb_subnet_id       = var.lb_subnet_id
  lb_backend_subnets = var.lb_backend_subnets
  lb_listeners       = { for k, v in var.lb_listeners : v.port => v }
  lb_backend_pools   = { for k, v in var.lb_backend_pools : v.name => v }
  lb_pool_members = flatten([
    for k, v in var.lb_backend_pools : [
      for i, j in v.members : merge({ pool_name = v.name }, j)
    ]
  ])
  lb_policys = { for k, v in var.lb_policys : v.name => v }
  lb_policy_rules = flatten([
    for k, v in var.lb_policys : [
      for i, j in v.rules : merge({ policy_name = v.name }, j)
    ]
  ])
}

resource "huaweicloud_vpc_eip" "this" {
  charging_mode = "postPaid"
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "eip_elb"
    size        = local.lb_bandwidth
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

data "huaweicloud_availability_zones" "this" {}

resource "huaweicloud_elb_loadbalancer" "this" {
  name           = local.lb_name
  vpc_id         = local.lb_vpc_id
  ipv4_subnet_id = local.lb_subnet_id
  ipv4_eip_id    = huaweicloud_vpc_eip.this.id

  availability_zone = [
    data.huaweicloud_availability_zones.this.names[0],
    data.huaweicloud_availability_zones.this.names[1]
  ]
  backend_subnets = local.lb_backend_subnets
}

resource "huaweicloud_elb_listener" "this" {
  for_each = local.lb_listeners

  loadbalancer_id = huaweicloud_elb_loadbalancer.this.id
  name            = each.name
  protocol        = each.protocol
  protocol_port   = each.port

  idle_timeout                = 60
  request_timeout             = 60
  response_timeout            = 60
  advanced_forwarding_enabled = each.protocol == "HTTPS" ? true : false
  server_certificate          = each.protocol == "HTTPS" ? each.cert_id : null
}

resource "huaweicloud_elb_pool" "this" {
  for_each = local.lb_backend_pools

  vpc_id          = local.lb_vpc_id
  loadbalancer_id = huaweicloud_elb_loadbalancer.this.id
  name            = each.name
  protocol        = each.protocol
  lb_method       = each.method
  type            = each.type
}

resource "huaweicloud_elb_member" "this" {
  for_each = local.lb_pool_members

  pool_id       = huaweicloud_elb_pool.this[each.pool_name].id
  subnet_id     = each.subnet_id
  address       = each.address
  protocol_port = each.port
}

resource "huaweicloud_lb_l7policy" "this" {
  for_each = local.lb_policys

  name                 = each.name
  action               = each.action
  position             = each.position
  listener_id          = huaweicloud_elb_listener.this[each.listener_port].id
  redirect_pool_id     = each.redirect_pool_name != null ? huaweicloud_elb_pool.this[each.redirect_pool_name].id : null
  redirect_listener_id = each.redirect_listener_port != null ? huaweicloud_elb_listener.this[each.redirect_listener_port].id : null
}

resource "huaweicloud_elb_l7rule" "this" {
  for_each = local.lb_policy_rules

  l7policy_id  = huaweicloud_lb_l7policy.this[each.policy_name].id
  type         = each.type
  compare_type = each.compare_type
  conditions {
    value = each.condition_value
  }
}
