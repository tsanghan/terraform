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
  version = "~> 1.2"
}
# image resources
resource "lxd_cached_image" "bionic" {
  source_remote = "ubuntu-daily"
  source_image = "bionic"
}
resource "lxd_cached_image" "centos7" {
  source_remote = "images"
  source_image  = "centos/7"
}
# containers
resource "lxd_container" "ubuntu" {
  count = 3
  config     = {}
  ephemeral  = false
  limits     = {
      "memory" = "512MB"
      "cpu" = 1
  }
  name       = "ubuntu${count.index + 1}"
  profiles   = [
      "default", "ansible-class", "ubuntu${count.index + 1}"
  ]
  image      = lxd_cached_image.bionic.fingerprint
  wait_for_network = false
}

resource "lxd_container" "centos" {
  count = 3
  config     = {}
  ephemeral  = false
  limits     = {
      "memory" = "512MB"
      "cpu" = 1
  }
  name       = "centos${count.index +1}"
  profiles   = [
      "default", "ansible-class", "centos${count.index +1}"
  ]
  image      = lxd_cached_image.centos7.fingerprint
  wait_for_network = false
}
# lxd_profile.ansible_class
resource "lxd_profile" "ansible_class" {
    config = {
        "limits.cpu"       = "1"
        "limits.memory"    = "256MB"
        "security.nesting" = "true"
        "user.user-data"   = <<-EOT
            #cloud-config
            apt:
              preserve_sources_list: false
              primary:
                - arches:
                  - amd64
                  uri: "http://mirror.0x.sg/ubuntu/"
              security:
                - arches:
                  - amd64
                  uri: "http://security.ubuntu.com/ubuntu/"
            packages:
            groups:
              - localadmin
            users:
              - name: localadmin
                gecos: localadmin
                primary-group: localadmin
                groups: admin, docker
                shell: /bin/bash
                sudo: ALL=(ALL) NOPASSWD:ALL
            locale: C.UTF-8
            locale_configfile: /etc/default/locale
        EOT
    }
    name   = "ansible-class"

    device {
        name       = "eth1"
        properties = {
            "nictype" = "bridged"
            "parent"  = "lxdbr1"
        }
        type       = "nic"
    }
}

# lxd_profile.centos:
resource "lxd_profile" "centos" {
    count = 3
    config = {
        "user.network-config" = <<-EOT
            version: 1
            config:
              - type: physical
                name: eth0
                subnets:
                  - type: dhcp
                    ipv4: true
                    control: auto
              - type: physical
                name: eth1
                subnets:
                  - type: static
                    ipv4: true
                    address: 192.168.0.4${count.index + 5}
                    netmask: 255.255.255.0
                    control: auto
        EOT
    }
    name   = "centos${count.index +1}"
}

# lxd_profile.ubuntu:
resource "lxd_profile" "ubuntu" {
    count = 3
    config = {
        "user.network-config" = <<-EOT
            version: 1
            config:
              - type: physical
                name: eth0
                subnets:
                  - type: dhcp
                    ipv4: true
                    control: auto
              - type: physical
                name: eth1
                subnets:
                  - type: static
                    ipv4: true
                    address: 192.168.0.4${count.index + 2}
                    netmask: 255.255.255.0
                    control: auto
        EOT
    }
    name   = "ubuntu${count.index + 1}"
}
