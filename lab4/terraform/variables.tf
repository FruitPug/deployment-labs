variable "ubuntu_image" {
  default = "/home/user/vm-images/jammy-server-cloudimg-amd64.img"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_ed25519.pub"
}
