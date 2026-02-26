locals {
  bucket_name = var.bucket_name
  acl         = var.acl
}

resource "alicloud_oss_bucket" "this" {
  bucket = local.bucket_name
}

resource "alicloud_oss_bucket_acl" "this" {
  bucket     = alicloud_oss_bucket.this.bucket
  acl        = local.acl
  depends_on = [alicloud_oss_bucket_public_access_block.this]
}

resource "alicloud_oss_bucket_public_access_block" "this" {
  bucket              = alicloud_oss_bucket.this.bucket
  block_public_access = local.acl == "private" ? true : false
}
