# huaweicloud_vpn_gateway

如何在华为云与 AWS 之间建立 VPN 通道。

首先创建华为云资源，此时还没有创建 VPN 连接和配置客户网关。

```hcl
data "huaweicloud_vpn_gateway_availability_zones" "az" {
  flavor          = "professional1"
  attachment_type = "vpc"
}

module "huaweicloud_vpn_gateway" {
  source = "../../modules/huaweicloud_vpn_gateway"

  name               = "vpn_gateway"
  vpc_id             = module.huaweicloud_network.vpc_id
  subnet_id          = module.huaweicloud_network.subnet_ids["subnet_elb"]
  # 本地子网
  local_subnet_cidrs = ["10.2.0.0/16"]
  # 远端子网，应该避免和 AWS 部分重叠
  peer_subnet_cidrs  = ["10.1.0.0/16"]
  availability_zones = [
    data.huaweicloud_vpn_gateway_availability_zones.az.names[0],
    data.huaweicloud_vpn_gateway_availability_zones.az.names[1]
  ]
}
```

然后创建 AWS 资源，将华为云 VPN 网关关联的公网 IP 地址添加到 AWS 中，只需要用到一个 IP 地址。

```hcl
module "aws_vpn_gateway" {
  source = "../../modules/aws_vpn_gateway"

  name                        = "vpn_gateway"
  vpc_id                      = module.aws_network.vpc_id
  # 任意本地公有子网
  subnet_id                   = module.aws_network.public_subnet_ids["ap-southeast-1a"]
  # 关联到对应路由表
  route_table_ids             = [module.aws_network.nat_route_table_id]
  # 本地子网
  local_subnet_cidrs          = ["10.1.0.0/16"]
  # 远端子网，应该避免和华为云部分重叠
  peer_subnet_cidrs           = ["10.2.0.0/16"]
  customer_gateway_name       = "huaweicloud_vpn_gateway"
  customer_gateway_ip_address = module.huaweicloud_vpn_gateway.vpngw_eip_address[0]
}
```

将 AWS VPN 网关中的 preshared key 和 tunnel 地址信息配置到华为云中。

```hcl
module "huaweicloud_vpn_gateway" {
  source = "../../modules/huaweicloud_vpn_gateway"

  name               = "vpn_gateway"
  vpc_id             = module.huaweicloud_network.vpc_id
  subnet_id          = module.huaweicloud_network.subnet_ids["subnet_elb"]
  local_subnet_cidrs = ["10.2.0.0/16"]
  peer_subnet_cidrs  = ["10.1.0.0/16"]
  availability_zones = [
    data.huaweicloud_vpn_gateway_availability_zones.az.names[0],
    data.huaweicloud_vpn_gateway_availability_zones.az.names[1]
  ]
  # 使用第一个 eip 进行连接
  customer_gateways = [
    {
      name       = "tunnel_1"
      ip_address = module.aws_vpn_gateway.tunnel1_address
      psk        = module.aws_vpn_gateway.tunnel1_preshared_key
      eip_index  = 0
    },
    {
      name       = "tunnel_2"
      ip_address = module.aws_vpn_gateway.tunnel2_address
      psk        = module.aws_vpn_gateway.tunnel2_preshared_key
      eip_index  = 0
    }
  ]
}
```
