terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.104.0"
    }
  }
}

resource "proxmox_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.target_node
  url          = var.cloud_image_url
}

resource "proxmox_virtual_environment_vm" "k3s_server" {
  name        = var.vm_name
  description = "Kubernetes Control Plane & Worker on ${var.target_node}"
  node_name   = var.target_node
  bios        = "ovmf"

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
    floating  = 4096 
  }

  scsi_hardware = "virtio-scsi-single"

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

  initialization {
    #datastore_id = "local-lvm"
    interface = "scsi3"

    ip_config {
      ipv4 { address = "dhcp" }
    }

    user_data_file_id = "local:snippets/debian-cloud-config.yml"
  }

  operating_system { 
    type = "l26" 
  }

  tpm_state {
    version = "v2.0"
  }

  serial_device {}

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  efi_disk {
    datastore_id      = "local-lvm"
    pre_enrolled_keys = true
    type              = "4m"
  }

  vga {
    type = "qxl"
  }

  on_boot = true 
}