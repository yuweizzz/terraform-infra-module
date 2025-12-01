locals {
  vpc_name            = var.vpc_name
  vpc_cidr_block      = var.vpc_cidr_block
  vpc_private_subnets = var.vpc_private_subnets
  vpc_public_subnets  = var.vpc_public_subnets
  security_groups     = var.security_groups
  ingress_rules       = { for k, v in local.security_groups : v.name => v.ingress_rules }
  egress_rules        = { for k, v in local.security_groups : v.name => v.egress_rules }
  ingress_rules_list  = flatten([for k, v in local.ingress_rules : [for i, j in v : merge({ name = k }, j)]])
  egress_rules_list   = flatten([for k, v in local.egress_rules : [for i, j in v : merge({ name = k }, j)]])
}

# create vpc
resource "aws_vpc" "this" {
  cidr_block = local.vpc_cidr_block
  tags = {
    Name = local.vpc_name
  }
}

# write internet gateway to main route table
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

data "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "igw" {
  route_table_id         = data.aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# create subnet pre availability zone
resource "aws_subnet" "private" {
  for_each = local.vpc_private_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = {
    Name = "${each.key}-private"
  }
}

resource "aws_subnet" "public" {
  for_each = local.vpc_public_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = {
    Name = "${each.key}-public"
  }
}

# create nat gateway
resource "aws_eip" "this" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags = {
    Name = "${local.vpc_name}_nat"
  }
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "nat" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "this" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.this.id
}

# security groups
data "aws_security_group" "selected" {
  vpc_id = aws_vpc.this.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

resource "aws_security_group" "this" {
  for_each = { for k, v in local.security_groups : v.name => v.description }

  name        = each.key
  description = each.value
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = each.key
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  # "for_each" supports maps and sets of strings, but you have provided a set containing type object.
  for_each = tomap({ for k, v in local.ingress_rules_list : k => v })

  security_group_id = aws_security_group.this[each.value.name].id
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.ip_protocol == "-1" ? null : each.value.to_port
}

resource "aws_vpc_security_group_egress_rule" "this" {
  # "for_each" supports maps and sets of strings, but you have provided a set containing type object.
  for_each = tomap({ for k, v in local.egress_rules_list : k => v })

  security_group_id = aws_security_group.this[each.value.name].id
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.ip_protocol == "-1" ? null : each.value.to_port
}
