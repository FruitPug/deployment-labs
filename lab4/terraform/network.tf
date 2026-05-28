resource "libvirt_network" "lab4_network" {
  name = "lab4-network"

  domain = {
    name = "lab4.local"
  }

  forward = {
    mode = "nat"
  }

  ips = [
    {
      address = "10.10.0.1"
      prefix  = 24
      dhcp = {
        hosts = [
          {
            mac     = "52:54:00:00:00:11"
            ip      = "10.10.0.10"
            hostname = "worker"
          },
          {
            mac     = "52:54:00:00:00:22"
            ip      = "10.10.0.20"
            hostname = "db"
          }
        ]
      }
    }
  ]
}
