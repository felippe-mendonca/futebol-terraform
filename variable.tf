variable "openstack_password" {}
variable "openstack_hostname" {}

variable "image_base" {
  type = "string"
}

variable "instances" {
  type = "list"

  default = []
}
