output "bucket" {
  value = try(alicloud_oss_bucket.this.bucket, null)
}

output "intranet_endpoint" {
  value = try(alicloud_oss_bucket.this.intranet_endpoint, null)
}

output "extranet_endpoint" {
  value = try(alicloud_oss_bucket.this.extranet_endpoint, null)
}
