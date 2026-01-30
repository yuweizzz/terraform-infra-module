locals {
  lb_name            = var.name
  lb_bandwidth       = var.bandwidth
  lb_vpc_id          = var.vpc_id
  lb_subnet_id       = var.subnet_id
  lb_backend_subnets = var.backend_subnets
  ip_groups          = { for k, v in var.ip_groups : v.name => v }
  lb_listeners       = { for k, v in var.listeners : v.port => v }
  lb_backend_pools   = { for k, v in var.backend_pools : v.name => v }
  lb_pool_members = flatten([
    for k, v in var.backend_pools : [
      for i, j in v.members : merge({ pool_name = v.name }, j)
    ]
  ])
  lb_policys = { for k, v in var.policys : v.name => v }
  lb_policy_rules = flatten([
    for k, v in var.policys : [
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

resource "huaweicloud_elb_ipgroup" "this" {
  for_each = local.ip_groups

  name = each.value.name
  dynamic "ip_list" {
    for_each = each.value.ip_lists
    content {
      ip          = ip_list.value.ip
      description = ip_list.value.description
    }
  }
}

resource "huaweicloud_elb_listener" "this" {
  for_each = local.lb_listeners

  loadbalancer_id             = huaweicloud_elb_loadbalancer.this.id
  name                        = each.value.name
  protocol                    = each.value.protocol
  protocol_port               = each.value.port
  idle_timeout                = 60
  request_timeout             = 60
  response_timeout            = 60
  advanced_forwarding_enabled = each.value.protocol == "HTTPS" ? true : false
  server_certificate          = each.value.protocol == "HTTPS" ? each.value.cert_id : null
  access_policy               = each.value.access_policy
  ip_group_enable             = each.value.access_policy != null ? "true" : null
  ip_group                    = each.value.ip_group_name != null ? huaweicloud_elb_ipgroup.this[each.value.ip_group_name].id : null
}

resource "huaweicloud_elb_pool" "this" {
  for_each = local.lb_backend_pools

  vpc_id          = local.lb_vpc_id
  loadbalancer_id = huaweicloud_elb_loadbalancer.this.id
  name            = each.value.name
  protocol        = each.value.protocol
  lb_method       = each.value.method
  type            = each.value.type
}

resource "huaweicloud_elb_member" "this" {
  for_each = { for k, v in local.lb_pool_members : v.pool_name => v }

  pool_id       = huaweicloud_elb_pool.this[each.key].id
  subnet_id     = each.value.subnet_id
  address       = each.value.address
  protocol_port = each.value.port
}

resource "huaweicloud_lb_l7policy" "this" {
  for_each = local.lb_policys

  name                 = each.value.name
  action               = each.value.action
  position             = each.value.position
  listener_id          = huaweicloud_elb_listener.this[each.value.listener_port].id
  redirect_pool_id     = each.value.redirect_pool_name != null ? huaweicloud_elb_pool.this[each.value.redirect_pool_name].id : null
  redirect_listener_id = each.value.redirect_listener_port != null ? huaweicloud_elb_listener.this[each.value.redirect_listener_port].id : null
}

resource "huaweicloud_elb_l7rule" "this" {
  for_each = { for k, v in local.lb_policy_rules : v.policy_name => v }

  l7policy_id  = huaweicloud_lb_l7policy.this[each.key].id
  type         = each.value.type
  compare_type = each.value.compare_type
  conditions {
    value = each.value.condition_value
  }
}
