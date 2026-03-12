output "vpngw_id" {
  value = try(huaweicloud_vpn_gateway.this.id, null)
}

output "vpngw_eip_address" {
  value = try([ for k, v in huaweicloud_vpc_eip.this: v.address ], null)
}
