resource "libvirt_volume" "worker_disk" {
  name = "worker.qcow2"
  pool = "default"

  create = {
    content = {
      url    = "file://${var.ubuntu_image}"
      format = "qcow2"
    }
    permissions = {
      mode  = "0644"
      owner = "64055"  
      group = "993"    
    }
  }
}

resource "libvirt_volume" "db_disk" {
  name = "db.qcow2"
  pool = "default"

  create = {
    content = {
      url    = "file://${var.ubuntu_image}"
      format = "qcow2"
    }
    permissions = {
      mode  = "0644"
      owner = "64055"  
      group = "993"    
    }
  }
}

resource "libvirt_cloudinit_disk" "worker_cloudinit" {
  name      = "worker-cloudinit"
  user_data = file("${path.module}/cloud-init/worker.yaml")
  meta_data = ""
}

resource "libvirt_cloudinit_disk" "db_cloudinit" {
  name      = "db-cloudinit"
  user_data = file("${path.module}/cloud-init/db.yaml")
  meta_data = ""
}

resource "libvirt_domain" "worker" {
  name        = "worker"
  type        = "kvm"
  memory      = 2048
  memory_unit = "MiB"
  vcpu        = 2

  os = {
    type = "hvm"
  }

  features = {
    acpi = true
  }

  devices = {
    disks = [
      {
        device = "disk"
        driver = {
          name = "qemu"
          type = "qcow2"
        }
        source = {
          volume = {
            pool   = libvirt_volume.worker_disk.pool
            volume = libvirt_volume.worker_disk.name
          }
        }
        target = { dev = "vda", bus = "virtio" }
      },
      {
        device = "cdrom"
        driver = {
          name = "qemu"
          type = "raw"
        }
        source = {
          file = {
            file = libvirt_cloudinit_disk.worker_cloudinit.path
          }
        }
        target = { dev = "sda", bus = "sata" }
        read_only = true
      }
    ]

    interfaces = [
      {
        model = {
          type = "virtio"
        }
        mac = {
          address = "52:54:00:00:00:11"
        }
        source = {
          network = {
            network = libvirt_network.lab4_network.name
          }
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_type = "serial"
        target_port = 0
      }
    ]
  }

  running = true
}

resource "libvirt_domain" "db" {
  name        = "db"
  type        = "kvm"
  memory      = 2048
  memory_unit = "MiB"
  vcpu        = 2

  os = {
    type = "hvm"
  }

  features = {
    acpi = true
  }

  devices = {
    disks = [
      {
        device = "disk"
        driver = {
          name = "qemu"
          type = "qcow2"
        }
        source = {
          volume = {
            pool   = libvirt_volume.db_disk.pool
            volume = libvirt_volume.db_disk.name
          }
        }
        target = { dev = "vda", bus = "virtio" }
      },
      {
        device = "cdrom"
        driver = {
          name = "qemu"
          type = "raw"
        }
        source = {
          file = {
            file = libvirt_cloudinit_disk.db_cloudinit.path
          }
        }
        target = { dev = "sda", bus = "sata" }
        read_only = true
      }
    ]

    interfaces = [
      {
        model = {
          type = "virtio"
        }
        mac = {
          address = "52:54:00:00:00:22"
        }
        source = {
          network = {
            network = libvirt_network.lab4_network.name
          }
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_type = "serial"
        target_port = 0
      }
    ]
  }

  running = true
}
