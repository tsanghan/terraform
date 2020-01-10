# Variables
variable "bridge" {
  description = "The default bridge for containers"
  default = "lxdbr0"
  type = string
}
variable "storage_pool" {
  description = "The default storage pool for containers"
  default = "lxd"
  type = string
}
