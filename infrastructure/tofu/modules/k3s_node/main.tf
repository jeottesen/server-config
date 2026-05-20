terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.104.0"
    }
  }
}

resource "proxmox_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.target_node
  url          = var.cloud_image_url
}

resource "proxmox_virtual_environment_file" "debian_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    file_name = "${var.vm_name}-cloud-config.yaml"
    data = <<EOF
#cloud-config
users:
  - name: jotaro
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ${trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))}
      - ${trimspace(file(pathexpand("~/.ssh/ansible.pub")))}

package_upgrade: true
packages:
  - qemu-guest-agent

runcmd:
  - apt modernize-sources
  - systemctl enable --now qemu-guest-agent
EOF
  }
}

resource "proxmox_virtual_environment_vm" "k3s_server" {
  name        = var.vm_name
  description = "Kubernetes Control Plane & Worker on ${var.target_node}"
  node_name   = var.target_node

  smbios {
    serial = "ds=nocloud;h=${var.vm_name}" 
  }

  agent { enabled = true }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
    floating  = 1024 
  }

  operating_system { type = "l26" }

  initialization {
    datastore_id = "local-lvm"
    
    ip_config {
      ipv4 { address = "dhcp" }
    }

    user_account {
      username = "jotaro"
      keys = [
        trimspace(file(pathexpand("~/.ssh/id_ed25519.pub"))),
        trimspace(file(pathexpand("~/.ssh/ansible.pub")))
      ]
    }
    user_data_file_id = proxmox_virtual_environment_file.debian_cloud_config.id
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_download_file.debian_cloud_image.id
    interface    = "scsi0"
    size         = 20
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi1"
    size         = 100
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  efi_disk {
    datastore_id      = "local-lvm"
    pre_enrolled_keys = true
    type              = "4m"
  }

  on_boot = true 
}