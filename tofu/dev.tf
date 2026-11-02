
# --- Debian cloud image, download per Proxmox host ---

resource "proxmox_download_file" "debian_pve_dev" {
  provider     = proxmox.pve_dev
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve-dev"
  url          = var.proxmox_cloud_image_url
}

# --- Deploy to pve-dev ---

# --- Headless sandboxed dev environment on pve-dev ---
module "devbox" {
  source    = "./modules/proxmox_vm"
  providers = {
    proxmox = proxmox.pve_dev
  }

  target_node   = "pve-dev"
  vm_name       = "devbox"
  smbios_serial = "ds=nocloud;h=devbox"
  description   = "Headless Debian dev environment"
  image_file_id = proxmox_download_file.debian_pve_dev.id
  cores         = 6
  memory_mb     = 8192
  os_disk_gb    = 64
  
  vga_type   = "qxl"
  ssd_tuning = false
}