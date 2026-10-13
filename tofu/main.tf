terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.104.0"
    }
  }
}

# nuk Provider
provider "proxmox" {
  endpoint  = var.nuk01_api_url
  api_token = "${var.nuk01_api_token_id}=${var.nuk01_api_token_secret}"
  insecure  = true
}

# nuk-02 Provider
provider "proxmox" {
  alias     = "nuk02"
  endpoint  = var.nuk02_api_url
  api_token = "${var.nuk02_api_token_id}=${var.nuk02_api_token_secret}"
  insecure  = true
}

# pve-dev Provider
provider "proxmox" {
  alias     = "pve_dev"
  endpoint  = var.pve_dev_api_url
  api_token = "${var.pve_dev_api_token_id}=${var.pve_dev_api_token_secret}"
  insecure  = true
}

# --- Debian cloud image, downloaded once per Proxmox host ---

resource "proxmox_download_file" "debian_nuk" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "nuk"
  url          = var.proxmox_cloud_image_url
}

resource "proxmox_download_file" "debian_nuk_02" {
  provider     = proxmox.nuk02
  content_type = "import"
  datastore_id = "local"
  node_name    = "nuk-02"
  url          = var.proxmox_cloud_image_url
}

resource "proxmox_download_file" "debian_pve_dev" {
  provider     = proxmox.pve_dev
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve-dev"
  url          = var.proxmox_cloud_image_url
}

# --- Deploy to nuk ---
module "k3s_nuk_01" {
  source = "./modules/debian_vm"
  providers = {
    proxmox = proxmox
  }

  target_node   = "nuk"
  vm_name       = "k3s-server-01"
  description   = "Kubernetes Control Plane"
  image_file_id = proxmox_download_file.debian_nuk.id
  data_disks    = [{ size_gb = 100 }]

  enable_tpm = true
  vga_type   = "qxl"
  ssd_tuning = false
}

# --- Deploy to nuk-02 ---
module "k3s_nuk_02" {
  source = "./modules/debian_vm"
  providers = {
    proxmox = proxmox.nuk02 
  }

  target_node   = "nuk-02"
  vm_name       = "k3s-server-02"
  description   = "Kubernetes Worker"
  image_file_id = proxmox_download_file.debian_nuk_02.id
  data_disks    = [{ size_gb = 100 }]

  enable_tpm = true
  vga_type   = "qxl"
  ssd_tuning = false
}

# --- Deploy to pve-dev ---

# --- Headless dev environment on pve-dev ---
module "devbox" {
  source    = "./modules/debian_vm"
  providers = {
    proxmox = proxmox.pve_dev
  }

  target_node   = "pve-dev"
  vm_name       = "devbox"
  description   = "Headless Debian dev environment"
  image_file_id = proxmox_download_file.debian_pve_dev.id
  cores         = 4
  memory_mb     = 8192
  os_disk_gb    = 64
}
