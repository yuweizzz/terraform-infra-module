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

  ec2_instance_name = "ec2_001"
  ec2_instance_type = "t3.medium"
  ec2_root_volume_size = 50
  # ec2_specified_key = "ec2_key"
  ec2_import_key = "ec2_key"
  ec2_import_key_content = file("${path.module}/secrets/ec2_key.pub")
  ec2_subnet_id = module.aws_network.private_subnet_ids["ap-southeast-1a"]
  ec2_security_groups = [
    module.aws_network.security_group_ids["sg_ssh"]
  ]
}
