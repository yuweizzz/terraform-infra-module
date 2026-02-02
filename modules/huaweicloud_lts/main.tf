locals {
  name          = var.name
  ttl_in_days   = var.ttl_in_days
  log_streams   = { for k, v in var.log_streams : v.name => "1" }
  host_groups   = { for k, v in var.host_groups : v.name => v }
  host_accesses = { for k, v in var.host_accesses : v.name => v }
}

resource "huaweicloud_lts_group" "this" {
  group_name  = local.name
  ttl_in_days = local.ttl_in_days
}

resource "huaweicloud_lts_stream" "this" {
  for_each = local.log_streams

  group_id    = huaweicloud_lts_group.this.id
  stream_name = each.key
}

data "huaweicloud_lts_hosts" "this" {
  for_each = local.host_groups

  filter {
    host_name_list = each.value.host_name_list
    host_ip_list   = each.value.host_ip_list
  }
}

resource "huaweicloud_lts_host_group" "this" {
  for_each = local.host_groups

  name     = each.value.name
  type     = "linux"
  host_ids = [for host in data.huaweicloud_lts_hosts.this[each.value.name].hosts : "${host.host_id}"]
}

resource "huaweicloud_lts_host_access" "this" {
  for_each = local.host_accesses

  name           = each.key
  log_group_id   = huaweicloud_lts_group.this.id
  log_stream_id  = huaweicloud_lts_stream.this[each.value.stream_name].id
  host_group_ids = [for group in each.value.host_group_names : huaweicloud_lts_host_group.this[group].id]

  access_config {
    paths = each.value.log_paths

    single_log_format {
      mode = "system"
    }
  }
}
