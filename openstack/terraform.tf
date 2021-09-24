# vim: ai et ts=2 sw=2
variable "os_application_credential_id" {}
variable "os_application_credential_secret" {}
variable "os_auth_url" {}
variable "os_region" {}
variable "user_keypair" {}
variable "node_count" {}

# Configure the OpenStack Provider
provider "openstack" {
  application_credential_id = var.os_application_credential_id
  application_credential_secret = var.os_application_credential_secret
  auth_url    = var.os_auth_url
  region      = var.os_region
}

terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
    }
  }
}

data "openstack_images_image_v2" "debian11" {
  name = "debian-11-x86_64"
}

data "openstack_compute_flavor_v2" "flavor" {
  name = "standard.medium"
}

data "openstack_compute_keypair_v2" "user" {
  name = var.user_keypair
}

resource "openstack_compute_keypair_v2" "kubernetes" {
  name = "tf kubernetes keypair"
}

data "template_file" "cloud_config" {
  template = file("../files/cloud-config")
  vars = {
    user_key = data.openstack_compute_keypair_v2.user.public_key
    kubernetes_key = openstack_compute_keypair_v2.kubernetes.public_key
    kubernetes_privkey = openstack_compute_keypair_v2.kubernetes.private_key
  }
}

data "template_cloudinit_config" "config" {
  base64_encode = true
  part {
    content = data.template_file.cloud_config.rendered
  }
}

resource "openstack_compute_instance_v2" "node" {
  name            = "kube-node"
  image_id        = data.openstack_images_image_v2.debian11.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  security_groups = ["default"]
  key_pair        = "tf kubernetes keypair"
  count           = var.node_count
  user_data       = data.template_cloudinit_config.config.rendered
  network {
    name = "group-project-network"
  }
}

resource "openstack_compute_instance_v2" "master" {
  name            = "kube-master"
  image_id        = data.openstack_images_image_v2.debian11.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  security_groups = ["default"]
  key_pair        = "tf kubernetes keypair"
  user_data       = data.template_cloudinit_config.config.rendered
  metadata = {
    kubenodes = join(" ", openstack_compute_instance_v2.node[*].access_ip_v4)
  }
  network {
    name = "group-project-network"
  }
}

resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "public-muni-147-251-21-GROUP"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.master.id
}
