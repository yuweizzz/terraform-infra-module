output "tunnel1_address" {
  value = try(aws_vpn_connection.this.tunnel1_address, null)
}

output "tunnel1_preshared_key" {
  value = try(aws_vpn_connection.this.tunnel1_preshared_key, null)
}

output "tunnel2_address" {
  value = try(aws_vpn_connection.this.tunnel2_address, null)
}

output "tunnel2_preshared_key" {
  value = try(aws_vpn_connection.this.tunnel2_preshared_key, null)
}
