locals {
  name              = var.name
  vpc_id            = var.vpc_id
  route_table_ids   = var.route_propagation_table_ids
  customer_gateways = { for k, v in var.customer_gateways : v.name => v }
  vpn_connections   = { for k, v in var.vpn_connections : v.name => v }
  vpn_connection_routes = flatten([
    for k, v in var.vpn_connections : [
      for i, j in v.destination_cidr_block : {
        name                   = v.name
        destination_cidr_block = j
      }
    ]
  ])
}

resource "aws_customer_gateway" "this" {
  for_each = local.customer_gateways

  ip_address = each.value.ip_address
  type       = "ipsec.1"
  bgp_asn    = each.value.bgp_asn

  tags = {
    Name = each.value.name
  }
}

resource "aws_vpn_gateway" "this" {
  tags = {
    Name = local.name
  }
}

resource "aws_vpn_gateway_attachment" "this" {
  vpc_id         = local.vpc_id
  vpn_gateway_id = aws_vpn_gateway.this.id
}

resource "aws_vpn_gateway_route_propagation" "this" {
  for_each = { for k, v in local.route_table_ids : k => v }

  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = each.value
}

resource "aws_vpn_connection" "this" {
  for_each = local.vpn_connections

  vpn_gateway_id           = aws_vpn_gateway.this.id
  customer_gateway_id      = aws_customer_gateway.this[each.value.customer_gateway_name].id
  type                     = "ipsec.1"
  local_ipv4_network_cidr  = each.value.local_ipv4_network_cidr
  remote_ipv4_network_cidr = each.value.remote_ipv4_network_cidr
  static_routes_only       = each.value.static_routes_only
}

resource "aws_vpn_connection_route" "this" {
  for_each = { for k, v in local.vpn_connection_routes : k => v }

  destination_cidr_block = each.value.destination_cidr_block
  vpn_connection_id      = aws_vpn_connection.this[each.value.name].id
}
