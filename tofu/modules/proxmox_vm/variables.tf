# --- Identity (required) ---

variable "vm_name" {
  description = "VM name and cloud-init hostname"
  type        = string
}

variable "target_node" {
  description = "Proxmox node to create the VM on"
  type        = string
}

variable "image_file_id" {
  description = "ID of a downloaded OS image (content type import), e.g. proxmox_download_file.x.id"
  type        = string
}

# --- Identity (optional) ---

variable "vm_id" {
  description = "Fixed Proxmox VM ID; null lets Proxmox pick the next free one"
  type        = number
  default     = null
}

variable "description" {
  type    = string
  default = null
}

variable "tags" {
  type    = list(string)
  default = null
}

variable "smbios_serial" {
  description = "SMBIOS serial passed to the guest, e.g. a cloud-init datasource hint; null leaves the smbios block out"
  type        = string
  default     = null
}

variable "on_boot" {
  type     = bool
  default  = true
  nullable = false
}

# --- Sizing ---

variable "cores" {
  type     = number
  default  = 2
  nullable = false
}

variable "memory_mb" {
  description = "Dedicated RAM in MiB"
  type        = number
  default     = 4096
  nullable    = false

  validation {
    condition     = var.memory_mb >= 1024
    error_message = "memory_mb must be at least 1024."
  }
}

variable "floating_memory_mb" {
  description = "Minimum RAM ballooning may shrink to, in MiB; null means equal to memory_mb (no ballooning)"
  type        = number
  default     = null
}

variable "os_disk_gb" {
  type     = number
  default  = 20
  nullable = false
}

variable "data_disks" {
  description = "Extra disks attached as scsi1, scsi2 (scsi3 is the cloud-init drive)"
  type = list(object({
    size_gb      = number
    datastore_id = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(var.data_disks) <= 2
    error_message = "At most 2 data disks; scsi3 is reserved for cloud-init."
  }
}

# --- Storage / hardware ---

variable "datastore_id" {
  type     = string
  default  = "local-lvm"
  nullable = false
}

variable "ssd_tuning" {
  description = "Enable discard, ssd emulation and iothread on disks (returns freed space to thin LVM)"
  type        = bool
  default     = true
  nullable    = false
}

variable "enable_tpm" {
  type     = bool
  default  = false
  nullable = false
}

variable "secure_boot_keys" {
  description = "Pre-enroll the default Secure Boot keys (Microsoft) in the EFI disk; set false for images that aren't signed with them, e.g. Talos"
  type        = bool
  default     = true
  nullable    = false
}

variable "vga_type" {
  description = "serial0 for headless (console via qm terminal / xterm.js), std or qxl for a graphical console"
  type        = string
  default     = "serial0"
  nullable    = false
}

# --- Network ---

variable "bridge" {
  type     = string
  default  = "vmbr0"
  nullable = false
}

variable "vlan_id" {
  type     = number
  default  = 0
  nullable = false
}

variable "mac_address" {
  description = "Fixed MAC address (use a locally administered one, first byte 02, 06, 0A or 0E); null lets Proxmox generate one"
  type        = string
  default     = null
}

variable "ipv4_address" {
  description = "\"dhcp\" or a CIDR address like 192.168.1.30/24"
  type        = string
  default     = "dhcp"
  nullable    = false
}

variable "ipv4_gateway" {
  description = "Required when ipv4_address is static"
  type        = string
  default     = null
}

# --- Cloud-init ---

variable "user_data_file_id" {
  description = "Cloud-init user data snippet; null for images that have none (Talos)"
  type        = string
  default     = "local:snippets/debian-cloud-config.yml"
}