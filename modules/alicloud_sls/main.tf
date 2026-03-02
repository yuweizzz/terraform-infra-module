locals {
  project_name    = var.project_name
  description     = var.description
  logstores       = { for k, v in var.logstores : v.name => v }
  machine_groups  = { for k, v in var.machine_groups : v.name => v.ip_lists }
  logtail_configs = { for k, v in var.logtail_configs : v.config_name => v }
}

resource "alicloud_log_project" "this" {
  project_name = local.project_name
  description  = local.description
}

resource "alicloud_log_store" "this" {
  for_each = local.logstores

  project_name          = alicloud_log_project.this.project_name
  logstore_name         = each.key
  shard_count           = 2
  auto_split            = true
  max_split_shard_count = 64
  append_meta           = true
  retention_period      = each.value.retention_period
  mode                  = "standard"
}

resource "alicloud_log_store_index" "this" {
  for_each = local.logstores

  project  = alicloud_log_project.this.project_name
  logstore = alicloud_log_store.this[each.key].logstore_name
  full_text {
    case_sensitive = false
    token          = <<EOF
, '";=()[\",\"]{}?@&<>/:\n\t\r
EOF
  }
}

resource "alicloud_log_machine_group" "this" {
  for_each = local.machine_groups

  name          = each.key
  project       = alicloud_log_project.this.project_name
  identify_type = "ip"
  identify_list = each.value
}

resource "alicloud_logtail_config" "this" {
  for_each = local.logtail_configs

  project     = alicloud_log_project.this.project_name
  logstore    = alicloud_log_store.this[each.value.logstore_name].logstore_name
  name        = each.value.config_name
  input_type  = "file"
  output_type = "LogService"

  input_detail = jsonencode({
    "adjustTimezone" : false,
    "delayAlarmBytes" : 0,
    "delaySkipBytes" : 0,
    "discardNonUtf8" : false,
    "discardUnmatch" : true,
    "dockerFile" : false,
    "enableRawLog" : false,
    "enableTag" : false,
    "fileEncoding" : "utf8",
    "filePattern" : each.value.file_pattern,
    "localStorage" : true,
    "logPath" : each.value.log_path,
    "logTimezone" : "",
    "logType" : "common_reg_log",
    "logBeginRegex" : ".*",
    "regex" : "(.*)",
    "key" : [
      "content"
    ],
    "maxDepth" : 10,
    "maxSendRate" : -1,
    "preserve" : true,
    "preserveDepth" : 0,
    "priority" : 0,
    "sendRateExpire" : 0,
    "tailExisted" : false,
    "topicFormat" : "none",
    "timeFormat" : "",
    "filterKey" : [],
    "filterRegex" : [],
    "mergeType" : "topic",
    "sensitive_keys" : [],
  })
}

resource "alicloud_logtail_attachment" "this" {
  for_each = local.logtail_configs

  project             = alicloud_log_project.this.project_name
  logtail_config_name = alicloud_logtail_config.this[each.value.config_name].name
  machine_group_name  = alicloud_log_machine_group.this[each.value.machine_group_name].name
}
