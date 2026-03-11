provider "huaweicloud" {
  region = local.region
}

locals {
  region = "ap-southeast-1"
}

data "huaweicloud_availability_zones" "az" {}

module "huaweicloud_network" {
  source = "../../modules/huaweicloud_network"

  vpc_name       = "hongkong_vpc"
  vpc_cidr_block = "10.1.0.0/16"
  vpc_subnets = [
    {
      name       = "subnet_private"
      cidr       = "10.1.1.0/24"
      gateway_ip = "10.1.1.1"
    },
    {
      name       = "subnet_elb"
      cidr       = "10.1.2.0/24"
      gateway_ip = "10.1.2.1"
    }
  ]

  nat_gateway_spec        = "1"
  nat_gateway_subnet_name = "subnet_elb"
  nat_gateway_eips = [
    {
      eip_name      = "nat_eip_a"
      eip_bandwidth = 50
    }
  ]
  nat_gateway_snat_rules = [
    {
      subnet_name = "subnet_private"
      eip_name    = "nat_eip_a"
    }
  ]
  nat_gateway_dnat_rules = [
    {
      ecs                   = module.huaweicloud_ecs
      eip_name              = "nat_eip_a"
      protocol              = "tcp"
      internal_service_port = 80
      external_service_port = 8080
    }
  ]

  security_groups = [
    {
      name = "sg_ssh"
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
      name = "sg_rds"
    }
  ]
}

data "huaweicloud_images_image" "debian" {
  name = "Debian 12.0.0 64bit"
}

module "huaweicloud_ecs" {
  source = "../../modules/huaweicloud_ecs"

  instance_name     = "instance_1"
  admin_pass        = file("${path.module}/secrets/ecs_passwd")
  root_volume_size  = 50
  instance_type     = "t6.large.2"
  subnet_id         = module.huaweicloud_network.subnet_ids["subnet_private"]
  image_id          = data.huaweicloud_images_image.debian.id
  availability_zone = data.huaweicloud_availability_zones.az.names[0]
  security_groups = [
    module.huaweicloud_network.security_group_ids["sg_ssh"]
  ]
}

module "huaweicloud_rds" {
  source = "../../modules/huaweicloud_rds"

  name           = "instance_1"
  flavor_id      = "rds.mysql.n1.large.4"
  password       = file("${path.module}/secrets/rds_password")
  storage_size   = 50
  vpc_id         = module.huaweicloud_network.vpc_id
  subnet_id      = module.huaweicloud_network.subnet_ids["subnet_private"]
  security_group = module.huaweicloud_network.security_group_ids["sg_rds"]
  availability_zones = [
    data.huaweicloud_availability_zones.az.names[0]
  ]
  # timezone = "UTC+08:00"
}

module "huaweicloud_dcs" {
  source = "../../modules/huaweicloud_dcs"

  name      = "instance_1"
  vpc_id    = module.huaweicloud_network.vpc_id
  subnet_id = module.huaweicloud_network.subnet_ids["subnet_private"]
  flavor_id = "redis.single.xu1.large.4"
  capacity  = 4
  password  = file("${path.module}/secrets/dcs_passwd")
  whitelist = {
    group_name = "ecs"
    ip_address = [
      module.huaweicloud_ecs.access_ip_v4,
    ]
  }
  availability_zones = [
    data.huaweicloud_availability_zones.az.names[0]
  ]
}

module "huaweicloud_obs" {
  source = "../../modules/huaweicloud_obs"

  bucket_name = "obs-private"
}

module "huaweicloud_cert" {
  source = "../../modules/huaweicloud_certificate"

  region             = local.region
  cert_name          = "host.name"
  import_certificate = file("${path.module}/secrets/crt.pem")
  import_private_key = file("${path.module}/secrets/key.pem")
}

module "huaweicloud_loadbalancer" {
  source = "../../modules/huaweicloud_loadbalancer"

  name      = "application"
  bandwidth = 20
  vpc_id    = module.huaweicloud_network.vpc_id
  subnet_id = module.huaweicloud_network.subnet_ids["subnet_elb"]
  backend_subnets = [
    module.huaweicloud_network.subnet_ids["subnet_private"]
  ]
  availability_zones = [
    data.huaweicloud_availability_zones.az.names[0],
    data.huaweicloud_availability_zones.az.names[1]
  ]

  backend_pools = [
    {
      name = "http"
      members = [{
        subnet_id = module.huaweicloud_network.subnet_ids["subnet_private"]
        address   = module.huaweicloud_ecs.access_ip_v4
        port      = 80
      }]
    }
  ]

  ip_groups = [
    {
      name = "white_list"
      ip_lists = [
        {
          ip          = "1.1.1.1"
          description = "ip"
        }
      ]
    }
  ]

  listeners = [
    {
      name     = "http"
      protocol = "HTTP"
      port     = 80
    },
    {
      name          = "https"
      protocol      = "HTTPS"
      port          = 443
      cert_id       = module.huaweicloud_cert.cert_id
      access_policy = "white"
      ip_group_name = "white_list"
    }
  ]

  policys = [
    {
      name                   = "http_to_https"
      action                 = "REDIRECT_TO_LISTENER"
      position               = 1
      listener_port          = 80
      redirect_listener_port = 443
    },
    {
      name               = "application"
      action             = "REDIRECT_TO_POOL"
      position           = 1
      listener_port      = 443
      redirect_pool_name = "http"
      rules = [
        {
          type            = "HOST_NAME"
          compare_type    = "EQUAL_TO"
          condition_value = "host.com"
        }
      ]
    }
  ]
}

data "huaweicloud_vpn_gateway_availability_zones" "az" {
  flavor          = "professional1"
  attachment_type = "vpc"
}

module "huaweicloud_vpn_gateway" {
  source = "../../modules/huaweicloud_vpn_gateway"

  name               = "vpn_gateway"
  vpc_id             = module.huaweicloud_network.vpc_id
  subnet_id          = module.huaweicloud_network.subnet_ids["subnet_elb"]
  local_subnet_cidrs = ["10.1.1.0/24"]
  peer_subnet_cidrs  = ["10.11.0.0/16"]
  availability_zones = [
    data.huaweicloud_vpn_gateway_availability_zones.az.names[0],
    data.huaweicloud_vpn_gateway_availability_zones.az.names[1]
  ]

  customer_gateways = [
    {
      name       = "tunnel_1"
      ip_address = "1.1.1.1"
      psk        = "tunnel_1_psk"
      eip_index  = 0
    },
    {
      name       = "tunnel_2"
      ip_address = "2.2.2.2"
      psk        = "tunnel_2_psk"
      eip_index  = 0
    }
  ]
}

module "huaweicloud_lts" {
  source = "../../modules/huaweicloud_lts"

  name = "log_group"
  log_streams = [
    {
      name = "app1"
    },
    {
      name = "app2"
    },
    {
      name = "nginx"
    }
  ]
  host_groups = [
    {
      name         = "nginx"
      host_ip_list = [module.huaweicloud_ecs.access_ip_v4]
    }
  ]
  host_accesses = [
    {
      name             = "nginx"
      stream_name      = "nginx"
      host_group_names = ["nginx"]
      log_paths        = ["/var/log/nginx/*.log"]
    }
  ]
}
