locals {
  name              = var.name
  vpc_id            = var.vpc_id
  connect_subnet    = var.subnet_id
  local_subnets     = var.local_subnet_cidrs
  peer_subnets      = var.peer_subnet_cidrs
  eip_bandwidth     = var.eip_bandwidth
  customer_gateways = { for k, v in var.customer_gateways : v.name => v }
}

resource "huaweicloud_vpc_eip" "this" {
  count = 2

  charging_mode = "postPaid"
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "vpn_gateway_eip_${count.index + 1}"
    size        = local.eip_bandwidth
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

data "huaweicloud_vpn_gateway_availability_zones" "az" {
  flavor          = "professional1"
  attachment_type = "vpc"
}

resource "huaweicloud_vpn_gateway" "this" {
  name            = local.name
  network_type    = "public"
  attachment_type = "vpc"
  vpc_id          = local.vpc_id
  connect_subnet  = local.connect_subnet
  local_subnets   = local.local_subnets
  availability_zones = [
    data.huaweicloud_vpn_gateway_availability_zones.az.names[0],
    data.huaweicloud_vpn_gateway_availability_zones.az.names[1]
  ]
  eip1 {
    id = huaweicloud_vpc_eip.this[0].id
  }
  eip2 {
    id = huaweicloud_vpc_eip.this[1].id
  }
  delete_eip_on_termination = true
  # ha_mode: "active-active" or "active-standby", default is "active-active"
  # ha_mode = "active-active"
  # flavor: "Basic", "Professional1" or "Professional2", default is "Professional1"
  # flavor = "Professional1"
}

resource "huaweicloud_vpn_customer_gateway" "this" {
  for_each = local.customer_gateways

  name     = each.value.name
  id_value = each.value.ip_address
  id_type  = "ip"
}

resource "huaweicloud_vpn_connection" "this" {
  for_each = local.customer_gateways

  name                = "${each.value.name}_connect"
  gateway_id          = huaweicloud_vpn_gateway.this.id
  gateway_ip          = huaweicloud_vpc_eip.this[each.value.eip_index].id
  customer_gateway_id = huaweicloud_vpn_customer_gateway.this[each.value.name].id
  peer_subnets        = local.peer_subnets
  vpn_type            = "static"
  psk                 = each.value.psk
}
