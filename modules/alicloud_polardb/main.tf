locals {
  cluster_name  = var.cluster_name
  db_node_class = var.db_node_class
  db_node_count = var.db_node_count
  vswitch_id    = var.vswitch_id
  standby_az    = var.standby_az
  security_ips  = var.security_ips
}

resource "alicloud_polardb_cluster" "this" {
  description   = local.cluster_name
  db_type       = "MySQL"
  db_version    = "8.0"
  db_node_class = local.db_node_class
  db_node_count = local.db_node_count

  # available zone, vswitch and standby_az should not same
  hot_standby_cluster = "ON"
  vswitch_id          = local.vswitch_id
  standby_az          = local.standby_az

  # PostPaid storage type, storage space is upto 100TB, the value here not take effect
  storage_pay_type = "PostPaid"
  storage_type     = "PSL5"
  storage_space    = 20

  tde_status             = "Disabled"
  lower_case_table_names = 1
  # Backup policy when delete cluster
  backup_retention_policy_on_cluster_deletion = "LATEST"

  pay_type = "PostPaid"
  # pay_type = "PrePaid"
  # period = "1"
  # renewal_status = "AutoRenewal"
  # auto_renew_period = "1"

  db_cluster_ip_array {
    db_cluster_ip_array_name = "default"
    security_ips = [
      "127.0.0.1"
    ]
  }
  db_cluster_ip_array {
    db_cluster_ip_array_name = "security_ips"
    security_ips             = var.security_ips
  }
}

# MYSQL standard: switch az quickly

# db_node_class = "polar.mysql.g2.small.c"
# db_node_count = 2  # fixed
# hot_standby_cluster = "EQUAL"
# vswitch_id = "ap-southeast-1a"  # vswitch in ap-southeast-1a
# standby_az = "ap-southeast-1b"
