# --- Talos image, built by the Image Factory and downloaded per Proxmox host ---
locals {
  talos_version      = "v1.14.5"
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = local.talos_version
  filters = {
    names = [
      "qemu-guest-agent",
      "iscsi-tools",
      "util-linux-tools",
      "i915",
      "netbird",
      "nvidia-open-gpu-kernel-modules-lts",
      "nvidia-container-toolkit-lts",
    ]
  }
}


resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
      }
    }
  })
}

data "talos_image_factory_urls" "this" {
  talos_version     = local.talos_version
  schematic_id      = talos_image_factory_schematic.this.id
  platform          = "nocloud"
  disk_image_format = "qcow2"
}

resource "proxmox_download_file" "talos_pve_mini_01" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve-mini-01"
  url          = data.talos_image_factory_urls.this.urls.disk_image_secureboot
  file_name    = "talos-${local.talos_version}-nocloud-amd64-secureboot.qcow2"
}

resource "proxmox_download_file" "talos_pve_mini_02" {
  provider     = proxmox.pve_mini_02
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve-mini-02"
  url          = data.talos_image_factory_urls.this.urls.disk_image_secureboot
  file_name    = "talos-${local.talos_version}-nocloud-amd64-secureboot.qcow2"
}

resource "proxmox_download_file" "talos_pve_dev" {
  provider     = proxmox.pve_dev
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve-dev"
  url          = data.talos_image_factory_urls.this.urls.disk_image_secureboot
  file_name    = "talos-${local.talos_version}-nocloud-amd64-secureboot.qcow2"
}


# --- Talos control plane  ---
module "k8s_cp_01" {
  source = "./modules/proxmox_vm"
  providers = {
    proxmox = proxmox
  }

  target_node   = "pve-mini-01"
  vm_name       = "k8s-cp-01"
  description   = "Talos control plane"
  image_file_id = proxmox_download_file.talos_pve_mini_01.id
  mac_address   = "02:4B:38:53:00:01"

  cores        = 4
  memory_mb    = 4096
  data_disks = [{ size_gb = 100 }, { size_gb = 5 }]
  ssd_tuning   = false

  user_data_file_id = null
  secure_boot_keys  = false
  vga_type          = "qxl"
}

module "k8s_cp_02" {
  source = "./modules/proxmox_vm"
  providers = {
    proxmox = proxmox.pve_mini_02
  }

  target_node   = "pve-mini-02"
  vm_name       = "k8s-cp-02"
  description   = "Talos control plane"
  image_file_id = proxmox_download_file.talos_pve_mini_02.id
  mac_address   = "02:4B:38:53:00:02"

  cores        = 4
  memory_mb    = 4096
  data_disks = [{ size_gb = 100 }, { size_gb = 5 }]
  ssd_tuning   = false

  user_data_file_id = null
  secure_boot_keys  = false
  vga_type          = "qxl"
}

module "k8s_cp_03" {
  source = "./modules/proxmox_vm"
  providers = {
    proxmox = proxmox.pve_dev
  }

  target_node   = "pve-dev"
  vm_name       = "k8s-cp-03"
  description   = "Talos control plane"
  image_file_id = proxmox_download_file.talos_pve_dev.id
  mac_address   = "02:4B:38:53:00:03"

  cores      = 4
  memory_mb  = 4096
  data_disks = [{ size_gb = 100 }, { size_gb = 5 }]

  user_data_file_id = null
  secure_boot_keys  = false
  vga_type          = "qxl"
}