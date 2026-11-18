variable "state_encryption_passphrase" {
  description = "Passphrase for OpenTofu state and plan encryption"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.state_encryption_passphrase) >= 16
    error_message = "Passphrase must be at least 16 characters."
  }
}

variable "pve_mini_01_api_url" {
  description = "The API URL for the first Proxmox node"
  type        = string
}

variable "pve_mini_01_api_token_id" {
  description = "The API Token ID for the first Proxmox node"
  type        = string
}

variable "pve_mini_01_api_token_secret" {
  description = "The API Token Secret for the first Proxmox node"
  type        = string
  sensitive   = true
}

variable "pve_mini_02_api_url" {
  description = "The API URL for the second Proxmox node"
  type        = string
}

variable "pve_mini_02_api_token_id" {
  description = "The API Token ID for the second Proxmox node"
  type        = string
}

variable "pve_mini_02_api_token_secret" {
  description = "The API Token Secret for the second Proxmox node"
  type        = string
  sensitive   = true
}

variable "pve_dev_api_url" {
  description = "The API URL for the second Proxmox node"
  type        = string
}

variable "pve_dev_api_token_id" {
  description = "The API Token ID for the second Proxmox node"
  type        = string
}

variable "pve_dev_api_token_secret" {
  description = "The API Token Secret for the second Proxmox node"
  type        = string
  sensitive   = true
}

# --- General Variables ---

variable "proxmox_cloud_image_url" {
  description = "The URL to the Debian cloud-init image"
  type        = string
}