locals {
  cluster_identifier                 = var.cluster_identifier
  engine                             = var.engine
  engine_version                     = var.engine_version
  master_username                    = var.master_username
  master_password                    = var.master_password
  subnet_group                       = var.subnet_group
  cluster_instance_type              = var.cluster_instance_type
  cluster_instance_num               = var.cluster_instance_num
  cluster_instance_prefix            = var.cluster_instance_prefix
  enabled_parameter_group_initialize = var.enabled_parameter_group_initialize
  cluster_parameter_group_name       = var.cluster_parameter_group_name
  instance_parameter_group_name      = var.instance_parameter_group_name
}

data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_db_subnet_group" "this" {
  count = length(local.subnet_group.subnet_ids) > 0 ? 1 : 0

  name       = local.subnet_group.name
  subnet_ids = local.subnet_group.subnet_ids
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = local.enabled_parameter_group_initialize ? 1 : 0

  name        = "aurora-mysql8-cluster"
  family      = "aurora-mysql8.0"
  description = "aurora mysql8 cluster"

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  parameter {
    name  = "long_query_time"
    value = 5
  }

  parameter {
    name  = "slow_query_log"
    value = 1
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Shanghai"
  }
}

resource "aws_db_parameter_group" "this" {
  count = local.enabled_parameter_group_initialize ? 1 : 0

  name        = "aurora-mysql8-instance"
  family      = "aurora-mysql8.0"
  description = "aurora mysql8 instance"

  parameter {
    name  = "long_query_time"
    value = 5
  }

  parameter {
    name  = "slow_query_log"
    value = 1
  }
}

resource "aws_rds_cluster" "this" {
  cluster_identifier              = local.cluster_identifier
  availability_zones              = data.aws_availability_zones.this.names
  engine                          = local.engine
  engine_version                  = local.engine_version
  master_username                 = local.master_username
  master_password                 = local.master_password
  storage_type                    = ""
  engine_lifecycle_support        = "open-source-rds-extended-support"
  database_insights_mode          = "standard"
  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "iam-db-auth-error", "slowquery"]

  db_cluster_parameter_group_name = local.cluster_parameter_group_name != null ? local.cluster_parameter_group_name : "aurora-mysql8-cluster"
  db_subnet_group_name            = length(local.subnet_group.subnet_ids) > 0 ? aws_db_subnet_group.this[0].name : local.subnet_group.name
}

resource "aws_rds_cluster_instance" "this" {
  count = local.cluster_instance_num

  identifier              = "${local.cluster_instance_prefix}-${count.index}"
  cluster_identifier      = aws_rds_cluster.this.id
  instance_class          = local.cluster_instance_type
  engine                  = local.engine
  engine_version          = local.engine_version
  db_parameter_group_name = local.instance_parameter_group_name != null ? local.instance_parameter_group_name : "aurora-mysql8-instance"
}
