output "vpngw_id" {
  value = try(huaweicloud_vpn_gateway.this.id, null)
}
