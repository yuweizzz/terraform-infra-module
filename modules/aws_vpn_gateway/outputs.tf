output "vpn_connections" {
  value = try({
    for k, v in aws_vpn_connection.this : k => {
      tunnel1_address       = v.tunnel1_address
      tunnel1_preshared_key = v.tunnel1_preshared_key
      tunnel2_address       = v.tunnel2_address
      tunnel2_preshared_key = v.tunnel2_preshared_key
    }
  }, null)
}
