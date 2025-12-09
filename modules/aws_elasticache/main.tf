locals {
  replication_group_id       = var.replication_group_id
  description                = var.description
  node_type                  = var.node_type
  num_cache_clusters         = var.num_cache_clusters
  engine                     = var.engine
  engine_version             = var.engine_version
  parameter_group_name       = var.parameter_group_name
  port                       = var.port
  cluster_mode               = var.cluster_mode
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.auth_token
  auth_token_update_strategy = var.auth_token_update_strategy
  subnet_group               = var.subnet_group
}

resource "aws_elasticache_subnet_group" "this" {
  count = length(local.subnet_group.subnet_ids) > 0 ? 1 : 0

  name       = local.subnet_group.name
  subnet_ids = local.subnet_group.subnet_ids
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = local.replication_group_id
  description                = local.description
  node_type                  = local.node_type
  num_cache_clusters         = local.num_cache_clusters
  engine                     = local.engine
  engine_version             = local.engine_version
  parameter_group_name       = local.parameter_group_name
  port                       = local.port
  cluster_mode               = local.cluster_mode
  transit_encryption_enabled = local.transit_encryption_enabled
  auth_token                 = local.auth_token
  auth_token_update_strategy = local.auth_token_update_strategy

  multi_az_enabled           = local.num_cache_clusters > 1 ? true : false
  automatic_failover_enabled = local.num_cache_clusters > 1 ? true : false
  subnet_group_name          = length(local.subnet_group.subnet_ids) > 0 ? aws_elasticache_subnet_group.this[0].name : local.subnet_group.name
}
