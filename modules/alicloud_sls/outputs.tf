output "project_id" {
  value = try(alicloud_log_project.this.id, null)
}
