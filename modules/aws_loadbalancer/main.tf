locals {
  lb_vpc_id          = var.lb_vpc_id
  lb_name            = var.lb_name
  lb_type            = var.lb_type
  lb_subnets         = var.lb_subnets
  lb_security_groups = var.lb_security_groups
  lb_target_groups = { for k, v in var.lb_target_groups : v.group_name => v }
  lb_target_group_attachments = flatten([
    for k, v in var.lb_target_groups : [
      for i, j in v.instances : merge({ group_name = v.group_name }, j)
    ]
  ])
  lb_net_rules     = { for k, v in var.lb_net_rules : k => v }
  lb_app_listener    = { for k, v in var.lb_app_rules : v.port => v }
  lb_app_listener_certs = flatten([
    for k, v in var.lb_app_rules : [
      for i, j in lookup(v, "extra_certs", []) : {
        port = v.port
        cert = j
      }
    ]
  ])
  lb_app_listener_rules = flatten([
    for k, v in var.lb_app_rules : [
      for i, j in v.rules : merge({ port = v.port }, j)
    ]
  ])
  lb_app_http_to_https = [for k, v in var.lb_app_rules : {
    http_port  = v.http_redirect_https_port
    https_port = v.port
  }]
}

resource "aws_lb_target_group" "this" {
  for_each = local.lb_target_groups

  name     = each.value.group_name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = local.lb_vpc_id
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = tomap({ for k, v in local.lb_target_group_attachments : k => v })

  target_group_arn = aws_lb_target_group.this[each.value.group_name].arn
  target_id        = each.value.instance_id
  port             = each.value.port
}

resource "aws_lb" "this" {
  name               = local.lb_name
  internal           = false
  load_balancer_type = local.lb_type
  subnets            = local.lb_subnets
  security_groups    = local.lb_security_groups
}

resource "aws_lb_listener" "net_listener" {
  for_each = local.lb_net_rules

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group].arn
  }
}

resource "aws_lb_listener" "app_listener" {
  for_each = local.lb_app_listener

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.protocol == "HTTPS" ? lookup(each.value, "ssl_policy", "ELBSecurityPolicy-TLS13-1-2-2021-06") : ""
  certificate_arn   = each.value.protocol == "HTTPS" ? each.value.default_cert : ""

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener_certificate" "this" {
  for_each = tomap({ for k, v in local.lb_app_listener_certs : k => v })

  listener_arn    = aws_lb_listener.app_listener[each.value.port].arn
  certificate_arn = each.value.cert
}


resource "aws_lb_listener" "redirects" {
  for_each = tomap({ for k, v in local.lb_app_http_to_https : k => v })

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.http_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      port        = each.value.https_port
      protocol    = "HTTPS"
    }
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = tomap({ for k, v in local.lb_app_listener_rules : k => v })

  listener_arn = aws_lb_listener.app_listener[each.value.port].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group].arn
  }

  condition {
    host_header {
      values = [each.value.host_name]
    }
  }
}
