output "vm_ips" {
  value = {
    "devbox"        = module.devbox.ipv4_address
    "k8s-cp-01"     = module.k8s_cp_01.ipv4_address
    "k8s-cp-02"     = module.k8s_cp_02.ipv4_address
    "k8s-cp-03"     = module.k8s_cp_03.ipv4_address
  }
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}