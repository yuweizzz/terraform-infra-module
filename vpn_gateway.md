# AWS <=> huaweicloud

如何在 AWS 与华为云之间建立 VPN 通道。

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
  # 本地子网，此时是华为云部分的 VPC cidr
  local_subnet_cidrs = ["10.2.0.0/16"]
  # 远端子网，此时是 AWS 部分的 VPC cidr
  peer_subnet_cidrs  = ["10.1.0.0/16"]
  availability_zones = [
    data.huaweicloud_vpn_gateway_availability_zones.az.names[0],
    data.huaweicloud_vpn_gateway_availability_zones.az.names[1]
  ]
}
```

然后创建 AWS 资源，将华为云 VPN 网关关联的公网 IP 地址添加到 AWS 中。

由于华为云的 VPN 网关提供了双 IP ，而在 AWS 的 VPN 连接资源中，会提供两个通道，但是两个通道只能同时连接到同一个客户网关，所以这里有两个选择：

- 创建单条 AWS VPN 连接，使用一个客户网关，将两个通道同时启用，对应的华为云 VPN 网关中的另一个 IP 不使用。
- 创建两条 AWS VPN 连接，使用两个客户网关，启用每个连接的单个通道，另一个不使用，对应的华为云 VPN 网关中的双 IP 都使用。

```hcl
# 使用单条 AWS VPN 连接
module "aws_vpn_gateway" {
  source = "../../modules/aws_vpn_gateway"

  name                        = "vpn_gateway"
  vpc_id                      = module.aws_network.vpc_id
  # 需要将路由传播到哪些内部路由表
  route_propagation_table_ids = [module.aws_network.nat_route_table_id]
  customer_gateways = [
    {
      name       = "huawei_1"
      ip_address = module.huaweicloud_vpn_gateway.vpngw_eip_address[0]
    }
  ]
  vpn_connections = [
    {
      name                     = "huawei_1"
      customer_gateway_name    = "huawei_1"
      # 这里比较反直觉，指定被允许通过 VPN 隧道进行通信的客户网关端的 cidr 范围，所以应该是华为云部分的 VPC cidr
      local_ipv4_network_cidr  = "10.2.0.0/16"
      # 同上，指定被允许通过 VPN 隧道进行通信的 AWS 端的 cidr 范围，所以应该是 AWS 部分的 VPC cidr
      remote_ipv4_network_cidr = "10.1.0.0/16"
      # 不使用 BGP 模式
      static_routes_only       = true
      # 对应的需要传播的路由信息，也就是华为云部分的 VPC cidr
      destination_cidr_block   = ["10.1.0.0/16"]
    }
  ]
}
```

将 AWS VPN 网关中的 preshared key 和 tunnel 地址信息配置到华为云中。

```hcl
# 使用单条 AWS VPN 连接
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
  # 只使用一个 eip 进行连接
  customer_gateways = [
    {
      name       = "tunnel_1"
      ip_address = module.aws_vpn_gateway.huawei_1.tunnel1_address
      psk        = module.aws_vpn_gateway.huawei_1.tunnel1_preshared_key
      eip_index  = 0
    },
    {
      name       = "tunnel_2"
      ip_address = module.aws_vpn_gateway.huawei_1.tunnel2_address
      psk        = module.aws_vpn_gateway.huawei_1.tunnel2_preshared_key
      eip_index  = 0
    }
  ]
}
```

以下是使用两条 AWS VPN 连接的资源文件：

```hcl
# 使用两条 AWS VPN 连接
module "aws_vpn_gateway" {
  source = "../../modules/aws_vpn_gateway"

  name                        = "vpn_gateway"
  vpc_id                      = module.aws_network.vpc_id
  route_propagation_table_ids = [module.aws_network.nat_route_table_id]
  customer_gateways = [
    {
      name       = "huawei_1"
      ip_address = module.huaweicloud_vpn_gateway.vpngw_eip_address[0]
    },
    {
      name       = "huawei_2"
      ip_address = module.huaweicloud_vpn_gateway.vpngw_eip_address[1]
    }
  ]
  vpn_connections = [
    {
      name                     = "huawei_1"
      customer_gateway_name    = "huawei_1"
      local_ipv4_network_cidr  = "10.2.0.0/16"
      remote_ipv4_network_cidr = "10.1.0.0/16"
      static_routes_only       = true
      destination_cidr_block   = ["10.1.0.0/16"]
    },
    {
      name                     = "huawei_2"
      customer_gateway_name    = "huawei_2"
      local_ipv4_network_cidr  = "10.2.0.0/16"
      remote_ipv4_network_cidr = "10.1.0.0/16"
      static_routes_only       = true
      destination_cidr_block   = ["10.1.0.0/16"]
    }
  ]
}

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
  customer_gateways = [
    {
      name       = "tunnel_1"
      ip_address = module.aws_vpn_gateway.huawei_1.tunnel1_address
      psk        = module.aws_vpn_gateway.huawei_1.tunnel1_preshared_key
      eip_index  = 0
    },
    {
      name       = "tunnel_2"
      ip_address = module.aws_vpn_gateway.huawei_2.tunnel1_address
      psk        = module.aws_vpn_gateway.huawei_2.tunnel1_preshared_key
      eip_index  = 1
    }
  ]
}
```

# AWS <=> alicloud

目前来看，只支持使用两条 AWS VPN 连接和阿里云的 VPN 网关进行连接。
