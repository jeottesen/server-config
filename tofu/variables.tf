# --- nuk-01 (Default Provider) Variables ---

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

# --- nuk-02 (Aliased Provider) Variables ---

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

# --- nuk-02 (Aliased Provider) Variables ---

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