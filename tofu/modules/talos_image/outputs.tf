output "talos_version" {
  description = "Talos version, e.g. v1.14.5"
  value       = local.talos_version
}

output "installer" {
  description = "Secure Boot installer image URL, used for installs and upgrades"
  value       = data.talos_image_factory_urls.this.urls.installer_secureboot
}

output "disk_image_url" {
  description = "Secure Boot qcow2 disk image URL, downloaded onto each Proxmox host"
  value       = data.talos_image_factory_urls.this.urls.disk_image_secureboot
}