# vim: ai et ts=2 sw=2
variable "one_endpoint" {}
variable "one_username" {}
variable "one_password" {}
variable "one_flow_endpoint" {}

provider "opennebula" {
  endpoint      = "${var.one_endpoint}"
  flow_endpoint = "${var.one_flow_endpoint}"
  username      = "${var.one_username}"
  password      = "${var.one_password}"
}

terraform {
  required_providers {
    opennebula = {
      source  = "opennebula/opennebula"
    }
  }
}

data "opennebula_template" "debian11" {
  name = "Debian 11"
}

data "opennebula_image" "debian11" {
  name = "Debian 11"
}

data "template_file" "master_init" {
  template = file("files/master.sh")
  vars = {
    private_key = file("files/id_ecdsa")
    public_key = file("files/id_ecdsa.pub")
  }
}

data "template_file" "node_init" {
  template = file("files/node.sh")
  vars = {
    private_key = file("files/id_ecdsa")
    public_key = file("files/id_ecdsa.pub")
  }
}

resource "opennebula_virtual_machine" "node" {
  count       = 1
  name        = "kube-node"
  template_id = data.opennebula_template.debian11.id
  cpu         = 4
  vcpu        = 4
  memory      = 4096
  disk {
    driver          = "raw"
    size            = 40000
    target          = "vda"
    image_id        = data.opennebula_image.debian11.id
  }
  context     = {
    START_SCRIPT_BASE64 = base64encode(data.template_file.node_init.rendered)
  }
}

resource "opennebula_virtual_machine" "master" {
  name        = "kube-master"
  template_id = data.opennebula_template.debian11.id
  cpu         = 4
  vcpu        = 4
  memory      = 4096
  disk {
    driver          = "raw"
    size            = 40000
    target          = "vda"
    image_id        = data.opennebula_image.debian11.id
  }
  context     = {
    START_SCRIPT_BASE64 = base64encode(data.template_file.master_init.rendered)
    KUBENODES = join(" ", opennebula_virtual_machine.node[*].ip)
  }
}

