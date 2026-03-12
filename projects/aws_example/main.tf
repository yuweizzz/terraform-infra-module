provider "aws" {
  region = local.region
}

locals {
  region = "ap-southeast-1"
}

data "aws_availability_zones" "az" {
  state = "available"
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
          cidr_ipv4 = "0.0.0.0/0"
        }
      ]
    }
  ]
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["debian-13-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "aws_ec2" {
  source = "../../modules/aws_ec2"

  instance_name      = "ec2_001"
  instance_type      = "t3.medium"
  ami_id             = data.aws_ami.debian.id
  root_volume_size   = 50
  import_key_name    = "ec2_key"
  import_key_content = file("${path.module}/secrets/ec2_key.pub")
  subnet_id          = module.aws_network.private_subnet_ids["ap-southeast-1a"]
  # associate_public_ip_address = true
  security_groups = [
    module.aws_network.security_group_ids["sg_ssh"]
  ]
}

# data "aws_key_pair" "key" {
#   filter {
#     name   = "key-name"
#     values = ["ec2_key"]
#   }
# }

module "aws_ec2_small" {
  source = "../../modules/aws_ec2"

  instance_name    = "ec2_002"
  instance_type    = "t3.small"
  ami_id           = data.aws_ami.debian.id
  root_volume_size = 50
  # specified_key_id = data.aws_key_pair.key[0].id
  specified_key_id = module.aws_ec2.ec2_key_id
  subnet_id        = module.aws_network.private_subnet_ids["ap-southeast-1a"]
  security_groups = [
    module.aws_network.security_group_ids["sg_ssh"]
  ]
}

module "aws_net_lb" {
  source = "../../modules/aws_loadbalancer"

  name   = "lb-net"
  vpc_id = module.aws_network.vpc_id
  type   = "network"
  subnet_ids = [
    module.aws_network.public_subnet_ids["ap-southeast-1a"],
    module.aws_network.public_subnet_ids["ap-southeast-1b"],
    module.aws_network.public_subnet_ids["ap-southeast-1c"],
  ]
  security_group_ids = [
    module.aws_network.security_group_ids["sg_ssh"]
  ]
  target_groups = [
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
  net_rules = [
    {
      port              = 22
      protocol          = "TCP"
      target_group_name = "ssh"
    }
  ]
}

module "aws_app_lb" {
  source = "../../modules/aws_loadbalancer"

  name   = "lb-app"
  vpc_id = module.aws_network.vpc_id
  type   = "application"
  subnet_ids = [
    module.aws_network.public_subnet_ids["ap-southeast-1a"],
    module.aws_network.public_subnet_ids["ap-southeast-1b"],
    module.aws_network.public_subnet_ids["ap-southeast-1c"],
  ]
  security_group_ids = [
    module.aws_network.security_group_ids["sg_ssh"]
  ]
  target_groups = [
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
  app_rules = [
    {
      port                     = 443
      protocol                 = "HTTPS"
      http_redirect_https_port = 80
      default_cert             = module.aws_cert_request.arn
      rules = [{
        host_name         = "www.host.com"
        target_group_name = "http"
        priority          = "1"
      }]
      # extra_certs = []
      # ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    }
  ]
}

# import cert
module "aws_cert_import" {
  source = "../../modules/aws_certificate"

  import_private_key      = file("${path.module}/secrets/key.pem")
  import_certificate_body = file("${path.module}/secrets/crt.pem")
}

# request cert
data "cloudflare_zone" "selected" {
  filter = {
    name = "host.com"
  }
}

module "aws_cert_request" {
  source = "../../modules/aws_certificate"

  request_dns_provider              = "cloudflare"
  request_domain_name               = "host.com"
  request_cloudflare_zone_id        = data.cloudflare_zone.selected.zone_id
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
  auth_token                 = file("${path.module}/secrets/redis_token")
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

# Base on aurora mysql 8.0
module "aws_rds" {
  source = "../../modules/aws_rds"

  cluster_identifier = "aurora-cluster"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.08.2"
  master_username    = "root"
  master_password    = file("${path.module}/secrets/mysql_password")
  subnet_group = {
    # create new subnet group with subnet_ids, use exist subnet group without subnet_ids
    name = "private-subnet"
    subnet_ids = [
      module.aws_network.private_subnet_ids["ap-southeast-1a"],
      module.aws_network.private_subnet_ids["ap-southeast-1b"],
      module.aws_network.private_subnet_ids["ap-southeast-1c"],
    ]
  }
  availability_zones      = data.aws_availability_zones.az.names
  cluster_instance_type   = "db.t4g.medium"
  cluster_instance_num    = 2
  cluster_instance_prefix = "db"
  # First time use this module, initialize parameter group and use it as default
  enabled_parameter_group_initialize = true
}

# New One
module "aws_rds_small" {
  source = "../../modules/aws_rds"

  cluster_identifier = "aurora-cluster-small"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.08.2"
  master_username    = "root"
  master_password    = file("${path.module}/secrets/mysql_password")
  subnet_group = {
    name = "private-subnet"
  }
  availability_zones      = data.aws_availability_zones.az.names
  cluster_instance_type   = "db.t4g.small"
  cluster_instance_num    = 1
  cluster_instance_prefix = "db"
  # Use parameter group initialize by aws_rds module
  cluster_parameter_group_name  = module.aws_rds.initialize_cluster_parameter_group_name
  instance_parameter_group_name = module.aws_rds.initialize_instance_parameter_group_name
  # Or default parameter group
  # cluster_parameter_group_name  = "default.aurora-mysql8.0"
  # instance_parameter_group_name = "default.aurora-mysql8.0"
}

module "aws_s3_private" {
  source = "../../modules/aws_s3"

  bucket_name = "s3-private"
}

module "aws_s3_public" {
  source = "../../modules/aws_s3"

  bucket_name       = "s3-public"
  allow_public_read = true
}
