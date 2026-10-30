terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.104.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.12.0"
    }
  }
  backend "s3" {
    bucket = "cobalt-tofu-state"
    key    = "proxmox/terraform.tfstate"
    region = "garage"
    profile = "garage-tofu"

    endpoints = {
      s3 = "http://mediaserver.samurai:3900"
    }
    use_path_style = true

    # Garage isn't AWS: skip the AWS-only checks
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

provider "proxmox" {
  endpoint  = var.pve_mini_01_api_url
  api_token = "${var.pve_mini_01_api_token_id}=${var.pve_mini_01_api_token_secret}"
  insecure  = true
}

provider "proxmox" {
  alias     = "nuk02"
  endpoint  = var.pve_mini_02_api_url
  api_token = "${var.pve_mini_02_api_token_id}=${var.pve_mini_02_api_token_secret}"
  insecure  = true
}

provider "proxmox" {
  alias     = "pve_mini_02"
  endpoint  = var.pve_mini_02_api_url
  api_token = "${var.pve_mini_02_api_token_id}=${var.pve_mini_02_api_token_secret}"
  insecure  = true
}

# pve-dev Provider
provider "proxmox" {
  alias     = "pve_dev"
  endpoint  = var.pve_dev_api_url
  api_token = "${var.pve_dev_api_token_id}=${var.pve_dev_api_token_secret}"
  insecure  = true
}

# --- Debian cloud image, download per Proxmox host ---

resource "proxmox_download_file" "debian_pve_dev" {
  provider     = proxmox.pve_dev
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve-dev"
  url          = var.proxmox_cloud_image_url
}

# --- Talos image, built by the Image Factory and downloaded per Proxmox host ---
locals {
  talos_version      = "v1.14.5"
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/qemu-guest-agent",
          "siderolabs/iscsi-tools",
          "siderolabs/util-linux-tools",
        ]
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
  content_type            = "import"
  datastore_id            = "local"
  node_name               = "nuk"
  url                     = data.talos_image_factory_urls.this.urls.disk_image
  file_name               = "talos-${local.talos_version}-nocloud-amd64.qcow2"
}

resource "proxmox_download_file" "talos_pve_mini_02" {
  provider                = proxmox.pve_mini_02
  content_type            = "import"
  datastore_id            = "local"
  node_name               = "pve-mini-02"
  url                     = data.talos_image_factory_urls.this.urls.disk_image
  file_name               = "talos-${local.talos_version}-nocloud-amd64.qcow2"
}

resource "proxmox_download_file" "talos_pve_dev" {
  provider                = proxmox.pve_dev
  content_type            = "import"
  datastore_id            = "local"
  node_name               = "pve-dev"
  url                     = data.talos_image_factory_urls.this.urls.disk_image
  file_name               = "talos-${local.talos_version}-nocloud-amd64.qcow2"
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
  cores         = 4
  memory_mb     = 4096
  os_disk_gb    = 64
  
  vga_type   = "qxl"
  ssd_tuning = false
}

# --- Talos control plane  ---
module "k8s_cp_01" {
  source = "./modules/proxmox_vm"
  providers = {
    proxmox = proxmox
  }

  target_node   = "nuk"
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