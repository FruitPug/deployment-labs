data "libvirt_domain_interface_addresses" "worker" {
  domain = libvirt_domain.worker.name
  source = "lease"
}

data "libvirt_domain_interface_addresses" "db" {
  domain = libvirt_domain.db.name
  source = "lease"
}

output "worker_ip" {
  value = "10.10.0.10"
}

output "db_ip" {
  value = "10.10.0.20"
}
