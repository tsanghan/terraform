# provider to connect to infrastructure
provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true
  lxd_remote {
    name     = "bionic-tf"
    scheme   = "https"
    address  = "10.1.1.40"
    password = "pass"
    default  = true
  }
}
# image resources
resource "lxd_cached_image" "ubuntu1804" {
  source_remote = "ubuntu"
  source_image = "18.04"
}
resource "lxd_cached_image" "centos7" {
  source_remote = "images"
  source_image  = "centos/7"
}
# containers
resource "lxd_container" "first" {
  config     = {}
  ephemeral  = false
  limits     = {
      "memory" = "128MB"
      "cpu" = 1
  }
  name       = "first"
  profiles   = [
      "terraform_default",
  ]
  image      = "lxd_cached_image.ubuntu1804"
  wait_for_network = false
}
resource "lxd_container" "second" {
  config     = {}
  ephemeral  = false
  limits     = {
      "memory" = "128MB"
      "cpu" = 1
  }
  name       = "second"
  profiles   = [
      "terraform_default",
  ]
  image      = "lxd_cached_image.centos7"
  wait_for_network = false
}
# Profile
resource "lxd_profile" "terraform_default" {
    config      = {}
    description = "Default LXD profile created by terrraform"
    name        = "terraform_default"
    device {
        name       = "root"
        properties = {
            "path" = "/"
            "pool" = "lxd"
        }
        type       = "disk"
    }

    device {
        name       = "eth0"
        properties = {
            "nictype" = "bridged"
            "parent" = "lxd_network.lxdbr0.name"
        }
        type       = "nic"
    }
}
# Storage Pool
#resource "lxd_storage_pool" "default" {
#  config = {
#      "size"   = "5GB"
#      "source" = "/var/lib/lxd/disks/default.img"
#      "zfs.pool_name" = "default"
#  }
#  driver = "zfs"
#  name   = "default"
#}
# Bridge Network
#resource "lxd_network" "lxdbr0" {
#  name = "lxdbr0"
#  description = "bridge interface for all containers to access hosts internet"
#  config = {
#    "ipv4.address" = "10.39.58.1/24"
#    "ipv4.nat"     = "true"
#    "ipv6.address" = "fd42:38a5:c677:b741::1/64"
#    "ipv6.nat"     = "true"
#  }
#}
output "second-ip" {
  value = lxd_container.second.ip_address
}
output "first-ip" {
  value = lxd_container.first.ip_address
}
