output "ubuntu-ip" {
  value = lxd_container.ubuntu[*].ip_address
}
output "centos-ip" {
  value = lxd_container.centos[*].ip_address
}
