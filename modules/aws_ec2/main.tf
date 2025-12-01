locals {
  ec2_instance_name               = var.ec2_instance_name
  ec2_instance_type               = var.ec2_instance_type
  ec2_ami                         = var.ec2_ami
  ec2_associate_public_ip_address = var.ec2_associate_public_ip_address
  ec2_subnet_id                   = var.ec2_subnet_id
  ec2_root_volume_size            = var.ec2_root_volume_size
  ec2_security_groups             = var.ec2_security_groups
  ec2_specified_key               = var.ec2_specified_key
  ec2_import_key                  = var.ec2_import_key
  ec2_import_key_content          = var.ec2_import_key_content
}

data "aws_key_pair" "selected" {
  filter {
    name   = "key-name"
    values = [local.ec2_specified_key]
  }
}

resource "aws_key_pair" "this" {
  count = local.ec2_import_key != "" ? 1 : 0

  key_name   = local.ec2_import_key
  public_key = local.ec2_import_key_content
}

resource "aws_instance" "this" {
  ami                         = local.ec2_ami
  instance_type               = local.ec2_instance_type
  key_name                    = local.ec2_specified_key != "" ? data.aws_key_pair.selected.id : resource.aws_key_pair.this[0].id
  associate_public_ip_address = local.ec2_associate_public_ip_address
  subnet_id                   = local.ec2_subnet_id
  vpc_security_group_ids      = local.ec2_security_groups
  root_block_device {
    volume_size = local.ec2_root_volume_size
    volume_type = "gp3"
  }
  tags = {
    Name = local.ec2_instance_name
  }
}
