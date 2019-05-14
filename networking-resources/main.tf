variable "openstack_password" {}
variable "openstack_hostname" {}

provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  domain_name = "Default"
  password    = "${var.openstack_password}"
  auth_url    = "http://${var.openstack_hostname}:5000"
  region      = "RegionOne"
  version     = "~> 1.4"
}

resource "openstack_networking_network_v2" "provider" {
  name = "provider"

  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_networking_subnet_v2" "provider" {
  name       = "provider"
  network_id = "${openstack_networking_network_v2.provider.id}"

  lifecycle {
    prevent_destroy = true
  }
}

output "provider_net_id" {
  value = "${openstack_networking_network_v2.provider.id}"
}

output "provider_subnet_id" {
  value = "${openstack_networking_subnet_v2.provider.id}"
}
