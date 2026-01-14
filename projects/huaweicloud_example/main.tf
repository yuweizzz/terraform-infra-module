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
          action    = "allow"
          cidr_ipv4 = "0.0.0.0/0"
        }
      ]
    },
    {
      name                 = "sg_rds"
      delete_default_rules = false
    }
  ]
}

module "huaweicloud_ecs" {
  source = "../../modules/huaweicloud_ecs"

  ecs_instance_name    = "instance_1"
  ecs_admin_pass       = file("${path.module}/secrets/ecs_passwd")
  ecs_root_volume_size = 50
  ecs_instance_type    = "t6.large.2"
  ecs_subnet_id        = module.huaweicloud_network.subnet_ids["subnet_private"]
  ecs_security_groups = [
    module.huaweicloud_network.security_group_ids["sg_ssh"]
  ]
}

module "huaweicloud_rds" {
  source = "../../modules/huaweicloud_rds"

  rds_name           = "instance_1"
  rds_flavor_id      = "rds.mysql.n1.large.4"
  rds_password       = file("${path.module}/secrets/rds_password")
  rds_storage_size   = 50
  rds_vpc_id         = module.huaweicloud_network.vpc_id
  rds_subnet_id      = module.huaweicloud_network.subnet_ids["subnet_private"]
  rds_security_group = module.huaweicloud_network.security_group_ids["sg_rds"]
  # rds_timezone = "UTC+08:00"
}

module "huaweicloud_dcs" {
  source = "../../modules/huaweicloud_dcs"

  dcs_name      = "instance_1"
  dcs_vpc_id    = module.huaweicloud_network.vpc_id
  dcs_subnet_id = module.huaweicloud_network.subnet_ids["subnet_private"]
  dcs_flavor_id = "redis.single.xu1.large.4"
  dcs_capacity  = 4
  dcs_password  = file("${path.module}/secrets/dcs_password")
  dcs_whitelist = {
    group_name = "ecs"
    ip_address = [
      module.huaweicloud_ecs.ecs_access_ip_v4,
    ]
  }
}

module "huaweicloud_cert" {
  source = "../../modules/huaweicloud_certificate"

  region             = local.region
  cert_name          = "host.name"
  import_certificate = file("${path.module}/secrets/crt.pem")
  import_private_key = file("${path.module}/secrets/key.pem")
}
