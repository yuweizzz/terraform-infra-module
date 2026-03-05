locals {
  name          = var.name
  server_groups = { for k, v in var.server_groups : v.name => v }
  server_group_members = flatten([
    for k, v in var.server_groups : [
      for i, j in v.members : merge({ name = v.name }, j)
    ]
  ])
  acl_groups = { for k, v in var.acl_groups : v.name => "1" }
  acl_group_entries = flatten([
    for k, v in var.acl_groups : [
      for i, j in v.entries : merge({ name = v.name }, { entry = j })
    ]
  ])
  certs             = { for k, v in var.certs : v.name => v }
  listeners         = { for k, v in var.listeners : v.name => v }
  domain_extensions = { for k, v in var.domain_extensions : k => v }
  rules             = { for k, v in var.rules : v.name => v }
}

resource "alicloud_slb_load_balancer" "this" {
  load_balancer_name   = local.name
  internet_charge_type = "PayByTraffic"
  address_type         = "internet"
  instance_charge_type = "PayByCLCU"
}

resource "alicloud_slb_server_group" "this" {
  for_each = local.server_groups

  load_balancer_id = alicloud_slb_load_balancer.this.id
  name             = each.key
}

resource "alicloud_slb_server_group_server_attachment" "this" {
  for_each = { for k, v in local.server_group_members : k => v }

  server_group_id = alicloud_slb_server_group.this[each.value.name].id
  type            = "ecs"
  server_id       = each.value.server_id
  port            = each.value.port
  weight          = each.value.weight
}

resource "alicloud_slb_acl" "this" {
  for_each = local.acl_groups

  name       = each.key
  ip_version = "ipv4"
}

resource "alicloud_slb_acl_entry_attachment" "this" {
  for_each = { for k, v in local.acl_group_entries : k => v }

  acl_id = alicloud_slb_acl.this[each.value.name].id
  entry  = each.value.entry
}

# create from alicloud_ssl_certificates_service_certificate
resource "alicloud_slb_server_certificate" "this" {
  for_each = local.certs

  name                           = each.key
  alicloud_certificate_id        = each.value.cert_ref_id
  alicloud_certificate_name      = each.value.cert_ref_name
  alicloud_certificate_region_id = each.value.region
}

resource "alicloud_slb_listener" "https" {
  for_each = { for k, v in local.listeners : k => v if v.protocol == "https" }

  load_balancer_id      = alicloud_slb_load_balancer.this.id
  description           = each.value.description
  frontend_port         = each.value.frontend_port
  backend_port          = each.value.backend_port
  protocol              = each.value.protocol
  server_certificate_id = alicloud_slb_server_certificate.this[each.value.default_cert].id
  bandwidth             = -1
  sticky_session        = "off"
  health_check          = "off"
  x_forwarded_for {
    retrive_slb_ip = true
    retrive_slb_id = true
  }
  acl_status      = each.value.acl_status
  acl_type        = each.value.acl_type
  acl_ids         = [for k, v in each.value.acl_groups : alicloud_slb_acl.this[v].id]
  request_timeout = 80
  idle_timeout    = 30
}

# http protocol only forward
resource "alicloud_slb_listener" "http" {
  for_each = { for k, v in local.listeners : k => v if v.protocol == "http" }

  load_balancer_id = alicloud_slb_load_balancer.this.id
  description      = each.value.description
  frontend_port    = each.value.frontend_port
  listener_forward = "on"
  forward_port     = each.value.forward_port
  protocol         = each.value.protocol
  depends_on       = [alicloud_slb_listener.https]
}

resource "alicloud_slb_rule" "this" {
  for_each = local.rules

  load_balancer_id = alicloud_slb_load_balancer.this.id
  name             = each.key
  domain           = each.value.domain
  server_group_id  = alicloud_slb_server_group.this[each.value.server_group_name].id
  frontend_port    = alicloud_slb_listener.https[each.value.listener_name].frontend_port
  sticky_session   = "off"
  listener_sync    = "off"
  scheduler        = "rr"
  health_check     = "off"
}

resource "alicloud_slb_domain_extension" "this" {
  for_each = local.domain_extensions

  load_balancer_id      = alicloud_slb_load_balancer.this.id
  frontend_port         = alicloud_slb_listener.https[each.value.listener_name].frontend_port
  domain                = each.value.domain
  server_certificate_id = alicloud_slb_server_certificate.this[each.value.cert_name].id
}
