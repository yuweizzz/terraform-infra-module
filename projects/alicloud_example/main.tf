provider "alicloud" {
  region = local.region
}

locals {
  region = "ap-southeast-1"
}

data "alicloud_zones" "available_zones" {
  available_resource_creation = "VSwitch"
}

module "alicloud_network" {
  source = "../../modules/alicloud_network"

  vpc_name       = "singapore_vpc"
  vpc_cidr_block = "10.1.0.0/16"
  vswitches = [
    {
      name       = "azone"
      cidr_block = "10.1.1.0/24"
      zone_id    = data.alicloud_zones.available_zones.zones.0.id
    }
  ]

  nat_gateway_name         = "singapore_nat_gateway"
  nat_gateway_vswitch_name = "azone"
  nat_gateway_eips = [
    {
      eip_name      = "nat_eip_a"
      eip_bandwidth = 50
    }
  ]
  nat_gateway_snat_rules = [
    {
      vswitch_name = "azone"
      eip_name     = "nat_eip_a"
    }
  ]
  nat_gateway_dnat_rules = [
    {
      ecs                   = module.alicloud_ecs
      eip_name              = "nat_eip_a"
      protocol              = "tcp"
      internal_service_port = 80
      external_service_port = 8080
    }
  ]

  security_groups = [
    {
      name        = "sg_ssh"
      description = "ssh"
      ingress_rules = [
        {
          ip_protocol = "tcp"
          cidr_ip     = "0.0.0.0/0"
          port_range  = "22"
        }
      ]
    }
  ]
}

module "alicloud_certificate" {
  source = "../../modules/alicloud_certificate"

  cert_name          = "host_com"
  import_certificate = file("${path.module}/secrets/crt.pem")
  import_private_key = file("${path.module}/secrets/key.pem")
}

module "alicloud_ecs" {
  source = "../../modules/alicloud_ecs"

  instance_name    = "instance-1"
  instance_type    = "ecs.c9a.large"
  vswitch_id       = module.alicloud_network.vswitch_ids["azone"]
  admin_pass       = file("${path.module}/secrets/ecs_passwd")
  root_volume_size = 50
  security_groups  = [module.alicloud_network.security_group_ids["sg_ssh"]]
}

module "alicloud_kvstore" {
  source = "../../modules/alicloud_kvstore"

  instance_name = "redis"
  vswitch_id    = module.alicloud_network.vswitch_ids["azone"]
  password      = file("${path.module}/secrets/kvstore_passwd")

  security_ips = [module.alicloud_ecs.private_ip]
}

module "alicloud_oss" {
  source = "../../modules/alicloud_oss"

  bucket_name = "private"
}

module "alicloud_rocketmq" {
  source = "../../modules/alicloud_rocketmq"

  vpc_id        = module.alicloud_network.vpc_id
  vswitch_id    = module.alicloud_network.vswitch_ids["azone"]
  instance_name = "rocketmq"
  ip_whitelists = [module.alicloud_ecs.private_ip]
}

module "alicloud_polardb" {
  source = "../../modules/alicloud_polardb"

  cluster_name = "polardb"
  vswitch_id   = module.alicloud_network.vswitch_ids["azone"]
  standby_az   = data.alicloud_zones.available_zones.zones.0.id
  security_ips = [module.alicloud_ecs.private_ip]
}

module "alicloud_sls" {
  source = "../../modules/alicloud_sls"

  project_name = "application"
  logstores = [
    { name = "nginx" }
  ]
  machine_groups = [
    {
      name     = "app"
      ip_lists = [module.alicloud_ecs.private_ip]
    }
  ]
  logtail_configs = [
    {
      config_name        = "nginx"
      logstore_name      = "nginx"
      machine_group_name = "app"
      log_path           = "/var/log/nginx"
      file_pattern       = "access-*.log"
    }
  ]
}

module "alicloud_loadbalancer" {
  source = "../../modules/alicloud_loadbalancer"

  name = "application"
  server_groups = [
    {
      name = "http"
      members = [{
        server_id = module.alicloud_ecs.ecs_id
        port      = 80
      }]
    }
  ]
  acl_groups = [
    {
      name    = "white_list"
      entries = ["1.1.1.1/32"]
    }
  ]
  certs = [
    {
      name          = "host_com"
      region        = local.region
      cert_ref_id   = module.alicloud_certificate.cert_id
      cert_ref_name = module.alicloud_certificate.cert_name
    },
    {
      name   = "domain_com"
      region = local.region
      # example
      cert_ref_id   = module.alicloud_certificate.cert_id
      cert_ref_name = module.alicloud_certificate.cert_name
    }
  ]
  listeners = [
    {
      name          = "http"
      protocol      = "http"
      frontend_port = 80
      forward_port  = 443
    },
    {
      name          = "https"
      protocol      = "https"
      frontend_port = 443
      backend_port  = 80
      default_cert  = "host_com"
      acl_status    = "on"
      acl_type      = "white"
      acl_groups    = ["white_list"]
    }
  ]
  domain_extensions = [
    {
      cert_name     = "domain_com"
      domain        = "www.domain.com"
      listener_name = "https"
    }
  ]
  rules = [
    {
      name              = "application"
      domain            = "www.host.com"
      listener_name     = "https"
      server_group_name = "http"
    },
    {
      name              = "application_1"
      domain            = "www.domain.com"
      listener_name     = "https"
      server_group_name = "http"
    }
  ]
}
