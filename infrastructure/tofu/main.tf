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
  ssh {
    agent    = true
    username = "jotaro"
  }
}

# nuk-02 Provider
provider "proxmox" {
  alias     = "nuk02"
  endpoint  = var.nuk02_api_url
  api_token = "${var.nuk02_api_token_id}=${var.nuk02_api_token_secret}"
  insecure  = true
  ssh {
    agent    = true
    username = "jotaro"
  }
}

# --- Deploy to nuk ---
module "k3s_nuk_01" {
  source = "./modules/k3s_node"
  
  providers = {
    proxmox = proxmox 
  }

  target_node     = "nuk"
  vm_name         = "k3s-server-01"
  cloud_image_url = var.proxmox_cloud_image_url
}

# --- Deploy to nuk-02 ---
module "k3s_nuk_02" {
  source = "./modules/k3s_node"
  
  providers = {
    proxmox = proxmox.nuk02 
  }

  target_node     = "nuk-02"
  vm_name         = "k3s-server-02"
  cloud_image_url = var.proxmox_cloud_image_url
}