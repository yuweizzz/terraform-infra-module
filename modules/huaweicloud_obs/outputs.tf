output "bucket_domain_name" {
  value = try(huaweicloud_obs_bucket.this.bucket_domain_name, null)
}
