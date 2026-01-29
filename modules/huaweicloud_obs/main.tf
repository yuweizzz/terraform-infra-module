locals {
  bucket_name   = var.bucket_name
  acl           = var.acl
  storage_class = var.storage_class
  multi_az      = var.multi_az
  region        = var.region
}

resource "huaweicloud_obs_bucket" "this" {
  bucket        = local.bucket_name
  acl           = local.acl
  storage_class = local.storage_class
  multi_az      = local.multi_az
  region        = local.region
}
