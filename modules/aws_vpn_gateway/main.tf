locals {
  name                        = var.name
  vpc_id                      = var.vpc_id
  route_table_ids             = var.route_propagation_table_ids
  local_subnet_cidr           = var.local_subnet_cidr
  peer_subnet_cidr            = var.peer_subnet_cidr
  customer_gateway_name       = var.customer_gateway_name
  customer_gateway_ip_address = var.customer_gateway_ip_address
}

resource "aws_customer_gateway" "this" {
  ip_address = local.customer_gateway_ip_address
  type       = "ipsec.1"

  tags = {
    Name = local.customer_gateway_name
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
  for_each = local.route_table_ids

  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = each.value
}

resource "aws_vpn_connection" "this" {
  vpn_gateway_id           = aws_vpn_gateway.this.id
  customer_gateway_id      = aws_customer_gateway.this.id
  type                     = "ipsec.1"
  local_ipv4_network_cidr  = local.local_subnet_cidr
  remote_ipv4_network_cidr = local.peer_subnet_cidr
}
