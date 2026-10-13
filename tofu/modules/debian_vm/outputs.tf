output "vm_id" {
  value = proxmox_virtual_environment_vm.this.vm_id
}

output "ipv4_address" {
  description = "First non-loopback IPv4 reported by the guest agent"
  value = try(
    [for ip in flatten(proxmox_virtual_environment_vm.this.ipv4_addresses) : ip if ip != "127.0.0.1"][0],
    null
  )
}