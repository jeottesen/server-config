# --- Talos image, built by the Image Factory and downloaded per Proxmox host ---
module "talos_image" {
  source = "../modules/talos_image"
}

# The schematic used to live in this root; keep its state entry.
moved {
  from = talos_image_factory_schematic.this
  to   = module.talos_image.talos_image_factory_schematic.this
}

resource "proxmox_download_file" "talos_pve_mini_01" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve-mini-01"
  url          = module.talos_image.disk_image_url
  file_name    = "talos-${module.talos_image.talos_version}-nocloud-amd64-secureboot.qcow2"
}

resource "proxmox_download_file" "talos_pve_mini_02" {
  provider     = proxmox.pve_mini_02
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve-mini-02"
  url          = module.talos_image.disk_image_url
  file_name    = "talos-${module.talos_image.talos_version}-nocloud-amd64-secureboot.qcow2"
}

resource "proxmox_download_file" "talos_pve_dev" {
  provider     = proxmox.pve_dev
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve-dev"
  url          = module.talos_image.disk_image_url
  file_name    = "talos-${module.talos_image.talos_version}-nocloud-amd64-secureboot.qcow2"
}


# --- Talos control plane  ---
module "k8s_cp_01" {
  source = "../modules/proxmox_vm"
  providers = {
    proxmox = proxmox
  }

  target_node   = "pve-mini-01"
  vm_name       = "k8s-cp-01"
  description   = "Talos control plane"
  image_file_id = proxmox_download_file.talos_pve_mini_01.id
  mac_address   = "02:4B:38:53:00:01"

  cores        = 4
  memory_mb    = 8192
  data_disks = [{ size_gb = 256 }, { size_gb = 5 }]
  ssd_tuning   = false

  user_data_file_id = null
  secure_boot_keys  = false
  vga_type          = "qxl"
}

module "k8s_cp_02" {
  source = "../modules/proxmox_vm"
  providers = {
    proxmox = proxmox.pve_mini_02
  }

  target_node   = "pve-mini-02"
  vm_name       = "k8s-cp-02"
  description   = "Talos control plane"
  image_file_id = proxmox_download_file.talos_pve_mini_02.id
  mac_address   = "02:4B:38:53:00:02"

  cores        = 4
  memory_mb    = 8192
  data_disks = [{ size_gb = 256 }, { size_gb = 5 }]
  ssd_tuning   = false

  user_data_file_id = null
  secure_boot_keys  = false
  vga_type          = "qxl"
}

module "k8s_cp_03" {
  source = "../modules/proxmox_vm"
  providers = {
    proxmox = proxmox.pve_dev
  }

  target_node   = "pve-dev"
  vm_name       = "k8s-cp-03"
  description   = "Talos control plane"
  image_file_id = proxmox_download_file.talos_pve_dev.id
  mac_address   = "02:4B:38:53:00:03"

  cores      = 4
  memory_mb  = 8192
  data_disks = [{ size_gb = 256 }, { size_gb = 5 }]

  user_data_file_id = null
  secure_boot_keys  = false
  vga_type          = "qxl"
}