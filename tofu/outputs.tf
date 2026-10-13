output "vm_ips" {
  value = {
    "k3s-server-01" = module.k3s_nuk_01.ipv4_address
    "k3s-server-02" = module.k3s_nuk_02.ipv4_address
    "devbox"        = module.devbox.ipv4_address
  }
}