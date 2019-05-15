# --- Providers
provider "openstack" {
  alias       = "admin"
  user_name   = "admin"
  tenant_name = "admin"
  domain_name = "Default"
  password    = "${var.openstack_password}"
  auth_url    = "http://${var.openstack_hostname}:5000"
  region      = "RegionOne"
  version     = "~> 1.4"
}

provider "openstack" {
  alias       = "exp22"
  user_name   = "admin"
  tenant_id   = "${openstack_identity_project_v3.exp22_project.id}"
  domain_name = "Default"
  password    = "${var.openstack_password}"
  auth_url    = "http://${var.openstack_hostname}:5000"
  region      = "RegionOne"
  version     = "~> 1.4"
}

# ---Identity configuration
data "openstack_identity_user_v3" "admin" {
  provider = "openstack.admin"
  name     = "admin"
}

data "openstack_identity_project_v3" "admin_project" {
  provider = "openstack.admin"
  name     = "admin"
}

resource "openstack_identity_project_v3" "exp22_project" {
  provider  = "openstack.admin"
  name      = "FUTEBOL+slice"
  enabled   = true
  parent_id = "${data.openstack_identity_project_v3.admin_project.id}"
  domain_id = "${data.openstack_identity_project_v3.admin_project.domain_id}"
}

resource "openstack_identity_role_v3" "exp22_role" {
  provider = "openstack.admin"
  name     = "FUTEBOL+role"
}

resource "openstack_identity_role_assignment_v3" "exp22_role_assignment" {
  provider   = "openstack.admin"
  user_id    = "${data.openstack_identity_user_v3.admin.id}"
  project_id = "${openstack_identity_project_v3.exp22_project.id}"
  role_id    = "${openstack_identity_role_v3.exp22_role.id}"
}

# --- Networking resources

data "openstack_networking_network_v2" "provider" {
  provider = "openstack.admin"
  name     = "provider"
}

data "openstack_networking_subnet_v2" "provider" {
  provider = "openstack.admin"
  name     = "provider"
}

resource "openstack_compute_keypair_v2" "keypair" {
  provider   = "openstack.admin"
  name       = "exp22_key"
  public_key = "${file("${var.public_key_path}")}"
}

resource "openstack_networking_secgroup_v2" "exp22_secgroup" {
  provider             = "openstack.admin"
  name                 = "exp22"
  tenant_id            = "${openstack_identity_project_v3.exp22_project.id}"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "exp22_segroup_rule_egress" {
  provider          = "openstack.admin"
  tenant_id         = "${openstack_identity_project_v3.exp22_project.id}"
  security_group_id = "${openstack_networking_secgroup_v2.exp22_secgroup.id}"

  direction = "egress"
  ethertype = "IPv4"
}

resource "openstack_networking_secgroup_rule_v2" "exp22_segroup_rule_ingress" {
  provider          = "openstack.admin"
  tenant_id         = "${openstack_identity_project_v3.exp22_project.id}"
  security_group_id = "${openstack_networking_secgroup_v2.exp22_secgroup.id}"

  direction = "ingress"
  ethertype = "IPv4"
}

resource "openstack_networking_port_v2" "instance_ports" {
  provider = "openstack.admin"
  count    = "${length(var.instances)}"

  name               = "${lookup(var.instances[count.index], "instance_name")}"
  network_id         = "${data.openstack_networking_network_v2.provider.id}"
  mac_address        = "${lookup(var.instances[count.index], "mac_address")}"
  tenant_id          = "${openstack_identity_project_v3.exp22_project.id}"
  security_group_ids = ["${openstack_networking_secgroup_v2.exp22_secgroup.id}"]
  admin_state_up     = "true"

  fixed_ip = [
    {
      subnet_id  = "${data.openstack_networking_subnet_v2.provider.id}"
      ip_address = "${lookup(var.instances[count.index], "ip_address")}"
    },
  ]
}

# --- Instances

data "openstack_images_image_v2" "image_base" {
  provider    = "openstack.admin"
  name        = "${var.image_base}"
  most_recent = true
}

resource "openstack_compute_instance_v2" "instances" {
  provider = "openstack.exp22"
  count    = "${length(var.instances)}"

  name        = "${lookup(var.instances[count.index], "instance_name")}"
  image_id    = "${data.openstack_images_image_v2.image_base.id}"
  flavor_name = "${lookup(var.instances[count.index], "flavor_name")}"
  key_pair    = "exp22_key"

  network {
    port = "${element(openstack_networking_port_v2.instance_ports.*.id, count.index)}"
  }

  connection {
    host        = "${lookup(var.instances[count.index], "ip_address")}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.privite_key_path}")}"
  }

  provisioner "remote-exec" {
    inline = "sudo /futebol/vms/${lookup(var.instances[count.index], "instance_name")}/run.bash"
  }
}
