variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type        = string
}

variable "proxmox_cloud_image_url" {
  type        = string
}

variable "proxmox_template_vmid" {
  type        = number
}

variable "proxmox_template_name" {
  type        = string
}

