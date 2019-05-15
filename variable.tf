variable "openstack_password" {}
variable "openstack_hostname" {}

variable "image_base" {
  type = "string"
}

variable "public_key_path" {
  type = "string"
}

variable "privite_key_path" {
  type = "string"
}

variable "instances" {
  type = "list"

  default = []
}
