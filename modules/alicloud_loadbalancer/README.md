# alicloud_loadbalancer

Replace certificate：

```hcl
# Old certificate
module "alicloud_certificate" {
  source = "../../modules/alicloud_certificate"

  cert_name          = "host_com"
  import_certificate = file("${path.module}/secrets/crt.pem")
  import_private_key = file("${path.module}/secrets/key.pem")
}

# New certificate
module "alicloud_certificate_new" {
  source = "../../modules/alicloud_certificate"

  cert_name          = "host_com_new"
  import_certificate = file("${path.module}/secrets/crt_new.pem")
  import_private_key = file("${path.module}/secrets/key_new.pem")
}

module "alicloud_loadbalancer" {
  source = "../../modules/alicloud_loadbalancer"

  certs = [
    {
      name          = "host_com"
      region        = local.region
      # Replace with new certificate
      cert_ref_id   = module.alicloud_certificate_new.cert_id
      cert_ref_name = module.alicloud_certificate_new.cert_name
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
      # "name" in certs 
      default_cert  = "host_com"
      acl_status    = "on"
      acl_type      = "white"
      acl_groups    = ["white_list"]
    }
  ]
  domain_extensions = [
    {
      # "name" in certs 
      cert_name     = "domain_com"
      domain        = "www.domain.com"
      listener_name = "https"
    }
  ]
}
```
