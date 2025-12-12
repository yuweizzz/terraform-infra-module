output "endpoint" {
  value = try(aws_rds_cluster.this.endpoint, null)
}

output "reader_endpoint" {
  value = try(aws_rds_cluster.this.reader_endpoint, null)
}

output "initialize_cluster_parameter_group_name" {
  value = try(aws_rds_cluster_parameter_group.this[0].name, null)
}

output "initialize_instance_parameter_group_name" {
  value = try(aws_db_parameter_group.this[0].name, null)
}
