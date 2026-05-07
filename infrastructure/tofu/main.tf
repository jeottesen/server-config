terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.104.0"
    }
  }
}

provider "proxmox" {
  endpoint      = var.proxmox_api_url
  api_token     = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure      = true
  ssh {
    agent = true
    username = "jotaro"  # required when using api_token
  }
}


resource "proxmox_download_file" "debian_cloud_image" {
  content_type = "import" # Usually 'iso' or 'import' depending on your storage
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = var.proxmox_cloud_image_url
}

resource "proxmox_virtual_environment_vm" "k3s_server" {
  name        = "k3s-server-01"
  description = "Kubernetes Control Plane & Worker"
  node_name   = "nuk"
  #vm_id       = 101 # Optional: specific ID

  smbios {
    # 'h' stands for hostname in NoCloud ds parameters
    serial = "ds=nocloud;h=k3s-server-01" 
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
    floating  = 1024 
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = "local-lvm"
    
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = "jotaro"
      keys = [
        trimspace(file(pathexpand("~/.ssh/id_ed25519.pub"))),
        trimspace(file(pathexpand("~/.ssh/ansible.pub")))
      ]
    }

    # Pulls keys from your local machine
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

  # EFI settings
  efi_disk {
    datastore_id      = "local-lvm"
    pre_enrolled_keys = true
    type              = "4m"
  }

  # Startup/Shutdown settings
  # Note: -1 in old provider is represented by omitting or specific flags in bpg
  on_boot = true 
}

# Create a separate file resource for Cloud-Init
resource "proxmox_virtual_environment_file" "debian_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    file_name = "debian-cloud-config.yaml"
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