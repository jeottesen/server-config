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
   # Run this to init. Only needed on first run or when changed.
  # `tofu init -backend-config=garage.s3.tfbackend`
  backend "s3" {
    key = "proxmox/terraform.tfstate"
  }
}

provider "proxmox" {
  endpoint  = var.pve_mini_01_api_url
  api_token = "${var.pve_mini_01_api_token_id}=${var.pve_mini_01_api_token_secret}"
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

