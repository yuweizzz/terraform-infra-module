terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.36.0"
    }
  }
}

locals {
  vpc_name                = var.vpc_name
  vpc_cidr_block          = var.vpc_cidr_block
  vpc_subnets             = { for k, v in var.vpc_subnets : v.name => v }
  nat_gateway_subnet_name = var.nat_gateway_subnet_name
  nat_gateway_spec        = var.nat_gateway_spec
  nat_gateway_eips        = { for k, v in var.nat_gateway_eips : v.eip_name => v.eip_bandwidth }
  nat_gateway_snat_rules  = { for k, v in var.nat_gateway_snat_rules : v.eip_name => v.subnet_name }
  security_groups         = { for k, v in var.security_groups : v.name => v.delete_default_rules }
  ingress_rules           = { for k, v in var.security_groups : v.name => v.ingress_rules }
  egress_rules            = { for k, v in var.security_groups : v.name => v.egress_rules }
  ingress_rules_list      = flatten([for k, v in local.ingress_rules : [for i, j in v : merge({ name = k }, j)]])
  egress_rules_list       = flatten([for k, v in local.egress_rules : [for i, j in v : merge({ name = k }, j)]])
}

resource "huaweicloud_vpc" "this" {
  name = local.vpc_name
  cidr = local.vpc_cidr_block
}

resource "huaweicloud_vpc_subnet" "this" {
  for_each = local.vpc_subnets

  vpc_id     = huaweicloud_vpc.this.id
  cidr       = each.value.cidr
  gateway_ip = each.value.gateway_ip
  name       = each.value.name
}

resource "huaweicloud_nat_gateway" "this" {
  name      = "${local.vpc_name}_nat_gateway"
  spec      = local.nat_gateway_spec
  vpc_id    = huaweicloud_vpc.this.id
  subnet_id = huaweicloud_vpc_subnet.this[local.nat_gateway_subnet_name].id
}

resource "huaweicloud_vpc_eip" "this" {
  for_each = local.nat_gateway_eips

  charging_mode = "postPaid"
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = each.key
    size        = each.value
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_nat_snat_rule" "this" {
  for_each = local.nat_gateway_snat_rules

  nat_gateway_id = huaweicloud_nat_gateway.this.id
  floating_ip_id = huaweicloud_vpc_eip.this[each.key].id
  subnet_id      = huaweicloud_vpc_subnet.this[each.value].id
}

resource "huaweicloud_networking_secgroup" "this" {
  for_each = local.security_groups

  name                 = each.key
  delete_default_rules = each.value
}

resource "huaweicloud_networking_secgroup_rule" "ingress" {
  for_each = tomap({ for k, v in local.ingress_rules_list : k => v })

  security_group_id = huaweicloud_networking_secgroup.this[each.value.name].id
  direction         = "ingress"
  ethertype         = "IPv4"
  action            = each.value.action
  protocol          = try(each.value.ip_protocol, null)
  ports             = try(each.value.ports, null)
  remote_ip_prefix  = each.value.cidr_ipv4
}

resource "huaweicloud_networking_secgroup_rule" "egress" {
  for_each = tomap({ for k, v in local.egress_rules_list : k => v })

  security_group_id = huaweicloud_networking_secgroup.this[each.value.name].id
  direction         = "egress"
  ethertype         = "IPv4"
  action            = each.value.action
  protocol          = try(each.value.ip_protocol, null)
  ports             = try(each.value.ports, null)
  remote_ip_prefix  = each.value.cidr_ipv4
}
