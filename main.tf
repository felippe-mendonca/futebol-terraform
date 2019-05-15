provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  domain_name = "Default"
  password    = "${var.openstack_password}"
  auth_url    = "http://${var.openstack_hostname}:5000"
  region      = "RegionOne"
  version     = "~> 1.4"
}

data "openstack_identity_user_v3" "admin" {
  name = "admin"
}

data "openstack_networking_network_v2" "provider" {
  name = "provider"
}

data "openstack_networking_subnet_v2" "provider" {
  name = "provider"
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "exp22_key"
  public_key = "${file("${var.public_key_path}")}"
}

# --- Instances
resource "openstack_networking_port_v2" "instance_ports" {
  count = "${length(var.instances)}"

  name           = "${lookup(var.instances[count.index], "instance_name")}"
  network_id     = "${data.openstack_networking_network_v2.provider.id}"
  mac_address    = "${lookup(var.instances[count.index], "mac_address")}"
  admin_state_up = "true"

  fixed_ip = [
    {
      subnet_id  = "${data.openstack_networking_subnet_v2.provider.id}"
      ip_address = "${lookup(var.instances[count.index], "ip_address")}"
    },
  ]
}

resource "openstack_compute_instance_v2" "instances" {
  count = "${length(var.instances)}"

  name            = "${lookup(var.instances[count.index], "instance_name")}"
  image_name      = "${var.image_base}"
  flavor_name     = "${lookup(var.instances[count.index], "flavor_name")}"
  key_pair        = "exp22_key"
  security_groups = ["default"]

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
