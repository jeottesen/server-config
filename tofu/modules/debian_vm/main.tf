terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.104.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.vm_name
  description = var.description
  node_name   = var.target_node
  vm_id       = var.vm_id
  tags        = var.tags
  bios        = "ovmf"
  on_boot     = var.on_boot

  smbios {
    serial = "ds=nocloud;h=${var.vm_name}"
  }

  agent { enabled = true }

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_mb
    floating  = coalesce(var.floating_memory_mb, var.memory_mb)
  }

  scsi_hardware = "virtio-scsi-single"

  # OS disk, imported from the cloud image
  disk {
    datastore_id = var.datastore_id
    import_from  = var.image_file_id
    interface    = "scsi0"
    size         = var.os_disk_gb
    discard      = var.ssd_tuning ? "on" : "ignore"
    ssd          = var.ssd_tuning
    iothread     = var.ssd_tuning
  }

  # Extra data disks: scsi1, scsi2
  dynamic "disk" {
    for_each = var.data_disks
    content {
      datastore_id = coalesce(disk.value.datastore_id, var.datastore_id)
      interface    = "scsi${disk.key + 1}"
      size         = disk.value.size_gb
      discard      = var.ssd_tuning ? "on" : "ignore"
      ssd          = var.ssd_tuning
      iothread     = var.ssd_tuning
    }
  }

  initialization {
    datastore_id = var.datastore_id
    interface    = "scsi3"

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    user_data_file_id = var.user_data_file_id
  }

  operating_system {
    type = "l26"
  }

  dynamic "tpm_state" {
    for_each = var.enable_tpm ? [1] : []
    content {
      datastore_id = var.datastore_id
      version      = "v2.0"
    }
  }

  serial_device {}

  vga {
    type = var.vga_type
  }

  network_device {
    bridge  = var.bridge
    model   = "virtio"
    vlan_id = var.vlan_id
  }

  efi_disk {
    datastore_id      = var.datastore_id
    pre_enrolled_keys = true
    type              = "4m"
  }

  lifecycle {
    # The image only matters when the VM is first created; after that apt keeps it updated.
    ignore_changes = [disk[0].import_from]
  }
}