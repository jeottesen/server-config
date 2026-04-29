terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_debug            = true
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "k3s_server" {
  name        = "k3s-server-01"
  target_node = "nuk"
  description = "Kubernetes Control Plane & Worker"

  os_type    = "cloud-init"
  clone      = "debian-13-cloudinit"
  full_clone = true
  agent      = 1 

  # Hardware specs
  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  # Top-level Memory settings
  memory  = 4096
  balloon = 1024
  

  bios    = "ovmf"
  scsihw  = "virtio-scsi-pci"
  boot    = "order=scsi0"
  hotplug = "network,disk,usb"
  
  efidisk {
    pre_enrolled_keys = true
    efitype = "4m"
    storage = "local-lvm"
  }

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size     = "20G"
          storage  = "local-lvm"
          backup   = true
        }
      }
      scsi1 {
        disk {
          size     = "100G"
          storage  = "local-lvm"
          backup   = true
        }
      }
    }
  }

  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  serial {
    id   = 0
    type = "socket"
  }

  # vga {
  #   type = "serial0"
  # }

  startup_shutdown {
    order            = -1
    shutdown_timeout = -1
    startup_delay    = -1
  }

  ipconfig0 = "ip=dhcp"
  ciuser    = "jotaro"
  ciupgrade = true

  sshkeys = <<-EOT
    ${file(pathexpand("~/.ssh/id_ed25519.pub"))}
    ${file(pathexpand("~/.ssh/ansible.pub"))}
  EOT
}