locals {
  vpc_id        = var.vpc_id
  vswitch_id    = var.vswitch_id
  instance_name = var.instance_name
  instance_type = var.instance_type
  ip_whitelists = var.ip_whitelists
}

resource "alicloud_rocketmq_instance" "this" {
  instance_name = local.instance_name
  ip_whitelists = local.ip_whitelists

  network_info {
    vpc_info {
      vpc_id = local.vpc_id
      vswitches {
        vswitch_id = local.vswitch_id
      }
    }
    internet_info {
      internet_spec = "disable"
      flow_out_type = "uninvolved"
    }
  }

  product_info {
    msg_process_spec = local.instance_type
    # Maximum
    message_retention_time = 720
  }
  service_code    = "rmq"
  series_code     = "standard"
  sub_series_code = "cluster_ha"
  payment_type    = "PayAsYouGo"
}
