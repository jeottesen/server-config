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

