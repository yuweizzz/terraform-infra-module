locals {
  vpc_name                 = var.vpc_name
  vpc_cidr_block           = var.vpc_cidr_block
  vswitches                = { for k, v in var.vswitches : v.name => v }
  nat_gateway_name         = var.nat_gateway_name
  nat_gateway_vswitch_name = var.nat_gateway_vswitch_name
  nat_gateway_eips         = { for k, v in var.nat_gateway_eips : v.eip_name => v.eip_bandwidth }
  nat_gateway_snat_rules   = { for k, v in var.nat_gateway_snat_rules : v.vswitch_name => v.eip_name }
  nat_gateway_dnat_rules   = { for k, v in var.nat_gateway_dnat_rules : k => v }
  security_groups          = { for k, v in var.security_groups : v.name => v.description }
  ingress_rules            = { for k, v in var.security_groups : v.name => v.ingress_rules }
  egress_rules             = { for k, v in var.security_groups : v.name => v.egress_rules }
  ingress_rules_list = flatten([
    for k, v in local.ingress_rules : [for i, j in v : merge({ name = k }, j)]
  ])
  egress_rules_list = flatten([
    for k, v in local.egress_rules : [for i, j in v : merge({ name = k }, j)]
  ])
}

resource "alicloud_vpc" "this" {
  vpc_name   = local.vpc_name
  cidr_block = local.vpc_cidr_block
}

resource "alicloud_vswitch" "this" {
  for_each = local.vswitches

  vpc_id       = alicloud_vpc.this.id
  vswitch_name = each.key
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
}

resource "alicloud_nat_gateway" "this" {
  vpc_id           = alicloud_vpc.this.id
  vswitch_id       = alicloud_vswitch.this[local.nat_gateway_vswitch_name].id
  nat_gateway_name = local.nat_gateway_name
  payment_type     = "PayAsYouGo"
  nat_type         = "Enhanced"
}

resource "alicloud_eip_address" "this" {
  for_each = local.nat_gateway_eips

  address_name         = each.key
  bandwidth            = each.value
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "this" {
  for_each = local.nat_gateway_eips

  instance_id   = alicloud_nat_gateway.this.id
  allocation_id = alicloud_eip_address.this[each.key].id
}

resource "alicloud_snat_entry" "this" {
  for_each = local.nat_gateway_snat_rules

  snat_table_id     = alicloud_nat_gateway.this.snat_table_ids
  source_vswitch_id = alicloud_vswitch.this[each.key].id
  snat_ip           = alicloud_eip_address.this[each.value].ip_address
}

resource "alicloud_forward_entry" "this" {
  for_each = local.nat_gateway_dnat_rules

  forward_table_id = alicloud_nat_gateway.this.forward_table_ids
  port_break       = true
  ip_protocol      = each.value.protocol
  external_ip      = alicloud_eip_address.this[each.value.eip_name].ip_address
  external_port    = each.value.external_service_port
  internal_ip      = each.value.ecs.private_ip
  internal_port    = each.value.internal_service_port
}


resource "alicloud_security_group" "this" {
  for_each = local.security_groups

  security_group_name = each.key
  description         = each.value
  vpc_id              = alicloud_vpc.this.id
}

resource "alicloud_security_group_rule" "ingress" {
  for_each = { for k, v in local.ingress_rules_list : k => v }

  security_group_id = alicloud_security_group.this[each.value.name].id
  type              = "ingress"
  ip_protocol       = each.value.ip_protocol
  policy            = each.value.policy
  port_range        = each.value.port_range
  priority          = each.value.priority
  cidr_ip           = each.value.cidr_ip
}

resource "alicloud_security_group_rule" "egress" {
  for_each = { for k, v in local.egress_rules_list : k => v }

  security_group_id = alicloud_security_group.this[each.value.name].id
  type              = "egress"
  ip_protocol       = each.value.ip_protocol
  policy            = each.value.policy
  port_range        = each.value.port_range
  priority          = each.value.priority
  cidr_ip           = each.value.cidr_ip
}
