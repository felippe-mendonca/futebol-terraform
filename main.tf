provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  domain_name = "Default"
  password    = "${var.openstack_password}"
  auth_url    = "http://${var.openstack_hostname}:5000"
  region      = "RegionOne"
  version     = "~> 1.4"
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "jfed_key"
  public_key = "${file("etc/id_rsa_jfed.pub")}"
}

data "openstack_identity_user_v3" "admin" {
  name = "admin"
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

# --- Instances
resource "openstack_networking_port_v2" "instance_ports" {
  count = "${length(var.instances)}"

  name           = "${lookup(var.instances[count.index], "instance_name")}"
  network_id     = "${openstack_networking_network_v2.provider.id}"
  admin_state_up = "true"
  mac_address    = "${lookup(var.instances[count.index], "mac_address")}"

  fixed_ip = [
    {
      subnet_id  = "${openstack_networking_subnet_v2.provider.id}"
      ip_address = "${lookup(var.instances[count.index], "ip_address")}"
    },
  ]
}

resource "openstack_compute_instance_v2" "instances" {
  count = "${length(var.instances)}"

  name            = "${lookup(var.instances[count.index], "instance_name")}"
  image_name      = "${var.instances}"
  flavor_name     = "${lookup(var.instances[count.index], "flavor_name")}"
  security_groups = ["default"]
  key_pair        = "jfed_key"

  network {
    port = "${element(openstack_networking_port_v2.instance_ports.*.id, count.index)}"
  }
}

resource "null_resource" "start_command" {
  count = "${length(var.instances)}"

  connection {
    host        = "${element(openstack_compute_instance_v2.instances.*.access_ip_v4, count.index)}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("etc/id_rsa_jfed")}"
  }

  provisioner "remote-exec" {
    inline = "sudo /futebol/vms/${lookup(var.instances[count.index], "instance_name")}/run.sh"
  }
}