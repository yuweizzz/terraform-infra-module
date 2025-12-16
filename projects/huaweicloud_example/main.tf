provider "huaweicloud" {
  region = local.region
}

locals {
  region = "ap-southeast-1"
}

module "huaweicloud_network" {
  source = "../../modules/huaweicloud_network"

  vpc_name       = "hongkong_vpc"
  vpc_cidr_block = "10.1.0.0/16"
  vpc_subnets = [{
    name       = "subnet_private"
    cidr       = "10.1.1.0/24"
    gateway_ip = "10.1.1.1"
  }]

  nat_gateway_spec        = "1"
  nat_gateway_subnet_name = "subnet_private"
  nat_gateway_eips = [{
    eip_name      = "nat_eip_a"
    eip_bandwidth = 50
  }]
  nat_gateway_snat_rules = [{
    subnet_name = "subnet_private"
    eip_name    = "nat_eip_a"
  }]

  security_groups = [
    {
      name                 = "sg_ssh"
      delete_default_rules = false
      ingress_rules = [
        {
          ports       = "22"
          action      = "allow"
          ip_protocol = "tcp"
          cidr_ipv4   = "0.0.0.0/0"
        }
      ]
      egress_rules = [
        {
          action      = "allow"
          cidr_ipv4   = "0.0.0.0/0"
        }
      ]
    }
  ]
}
