provider "aws" {
  region = local.region
}

locals {
  region = "ap-southeast-1"
}

module "aws_network" {
  source = "../../modules/aws_network"

  vpc_name       = "singapore_vpc"
  vpc_cidr_block = "10.0.0.0/16"
  vpc_private_subnets = {
    ap-southeast-1a = "10.0.0.0/24"
    ap-southeast-1b = "10.0.1.0/24"
    ap-southeast-1c = "10.0.2.0/24"
  }
  vpc_public_subnets = {
    ap-southeast-1a = "10.0.3.0/24"
    ap-southeast-1b = "10.0.4.0/24"
    ap-southeast-1c = "10.0.5.0/24"
  }
  security_groups = [
    {
      name        = "sg_ssh"
      description = "allow public ssh"
      ingress_rules = [
        {
          from_port   = 22
          to_port     = 22
          ip_protocol = "tcp"
          cidr_ipv4   = "0.0.0.0/0"
        }
      ]
      egress_rules = [
        {
          cidr_ipv4   = "0.0.0.0/0"
          ip_protocol = "-1"
        }
      ]
    }
  ]
}

module "aws_ec2" {
  source = "../../modules/aws_ec2"

  ec2_instance_name      = "ec2_001"
  ec2_instance_type      = "t3.medium"
  ec2_root_volume_size   = 50
  ec2_import_key         = "ec2_key"
  ec2_import_key_content = file("${path.module}/secrets/ec2_key.pub")
  ec2_subnet_id          = module.aws_network.private_subnet_ids["ap-southeast-1a"]
  ec2_security_groups = [
    module.aws_network.security_group_ids["sg_ssh"]
  ]

  # ec2_specified_key = "ec2_key"
  # ec2_associate_public_ip_address = true
}

module "aws_net_lb" {
  source = "../../modules/aws_loadbalancer"

  lb_vpc_id = module.aws_network.vpc_id
  lb_name   = "lb-net"
  lb_type   = "network"
  lb_subnets = [
    module.aws_network.public_subnet_ids["ap-southeast-1a"],
    module.aws_network.public_subnet_ids["ap-southeast-1b"],
    module.aws_network.public_subnet_ids["ap-southeast-1c"],
  ]
  lb_security_groups = [
    module.aws_network.security_group_ids["sg_ssh"]
  ]

  lb_target_groups = [
    {
      group_name = "ssh"
      protocol   = "TCP"
      port       = "22"
      instances = [{
        instance_id = module.aws_ec2.ec2_id
        port        = "22"
      }]
    },
  ]
  lb_net_rules = [
    {
      port         = "22"
      protocol     = "TCP"
      target_group = "ssh"
    }
  ]
}

module "aws_app_lb" {
  source = "../../modules/aws_loadbalancer"

  lb_vpc_id = module.aws_network.vpc_id
  lb_name   = "lb-app"
  lb_type   = "application"
  lb_subnets = [
    module.aws_network.public_subnet_ids["ap-southeast-1a"],
    module.aws_network.public_subnet_ids["ap-southeast-1b"],
    module.aws_network.public_subnet_ids["ap-southeast-1c"],
  ]
  lb_security_groups = [
    module.aws_network.security_group_ids["sg_ssh"]
  ]

  lb_target_groups = [
    {
      group_name = "http"
      protocol   = "HTTP"
      port       = "80"
      instances = [{
        instance_id = module.aws_ec2.ec2_id
        port        = "80"
      }]
    },
  ]
  lb_app_rules = [
    {
      port                     = "443"
      protocol                 = "HTTPS"
      http_redirect_https_port = "80"
      default_cert             = module.aws_cert_request.arn
      rules = [{
        host_name    = "www.host.com"
        target_group = "http"
        priority     = "1"
      }]
      # extra_certs = []
      # ssl_policy = ""
    }
  ]
}

# import cert
module "aws_cert_import" {
  source = "../../modules/aws_certificate"

  import_private_key      = file("${path.module}/key.pem")
  import_certificate_body = file("${path.module}/crt.pem")
}

# request cert
module "aws_cert_request" {
  source = "../../modules/aws_certificate"

  request_dns_provider              = "cloudflare"
  request_domain_name               = "host.com"
  request_subject_alternative_names = ["host.com", "*.host.com"]
}

module "aws_elasticache" {
  source = "../../modules/aws_elasticache"

  replication_group_id       = "redis"
  node_type                  = "cache.t4g.small"
  num_cache_clusters         = 2
  engine                     = "valkey"
  engine_version             = "8.2"
  parameter_group_name       = "default.valkey8"
  port                       = 6379
  description                = "valkey 8.2"
  cluster_mode               = "disabled"
  transit_encryption_enabled = true
  auth_token                 = file("${path.module}/redis_token")
  auth_token_update_strategy = "SET"
  subnet_group = {
    # create new subnet group with subnet_ids, use exist subnet group without subnet_ids 
    name = "private-subnet"
    subnet_ids = [
      module.aws_network.private_subnet_ids["ap-southeast-1a"],
      module.aws_network.private_subnet_ids["ap-southeast-1b"],
      module.aws_network.private_subnet_ids["ap-southeast-1c"],
    ]
  }
}
