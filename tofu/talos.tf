# --- Talos cluster: secrets, shared control-plane config, nodes, bootstrap, kubeconfig ---

locals {
  cluster_name       = "samurai-cluster"
  cluster_vip        = "192.168.50.214"
  kubernetes_version = "v1.37.1"

  talos_nodes = {
    "k8s-cp-01" = "192.168.50.215"
    "k8s-cp-02" = "192.168.50.216"
    "k8s-cp-03" = "192.168.50.217"
  }
}

resource "talos_machine_secrets" "this" {
  talos_version = local.talos_version
}

data "talos_client_configuration" "this" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = values(local.talos_nodes)
  nodes                = values(local.talos_nodes)
}



data "talos_machine_configuration" "controlplane" {
  cluster_name       = local.cluster_name
  cluster_endpoint   = "https://${local.cluster_vip}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = local.talos_version
  
  kubernetes_version = local.kubernetes_version

  config_patches = [
    # Update the modern unattended installation config with the Factory Image URL
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "UnattendedInstallConfig"
      installer = {
        image = data.talos_image_factory_urls.this.urls.installer
      }
      cluster = {
        allowSchedulingOnControlPlanes = true
      }
      provisioning = {
        diskSelector = {
          match = "system_disk"
        }
      }
    }),

    # Shared API address, held by one control plane node at a time
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "Layer2VIPConfig"
      name       = local.cluster_vip
      link       = "eth0"
    }),

    # The 100 GB data disk, mounted at /var/mnt/longhorn for Longhorn later
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "UserVolumeConfig"
      name       = "longhorn"
      provisioning = {
        diskSelector = {
          match = "!system_disk && disk.size >= 95u * GiB && disk.size <= 105u * GiB"
        }
        minSize = "90GiB"
        grow    = true
      }
    }),

     # Swap on the small extra disk (the system disk is excluded, and Longhorn's disk is over 50 GB)
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "SwapVolumeConfig"
      name       = "swap1"
      provisioning = {
        diskSelector = {
          match = "!system_disk && disk.size >= 3500u * MiB && disk.size <= 6000u * MiB"
        }
        maxSize = "4GiB"
      }
    }),

    # Let pods use swap (without this only the host can)
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "KubeletConfig"
      config = {
        memorySwap = {
          swapBehavior = "LimitedSwap"
        }
      }
    }),
  ]
}

# Built locally from the secrets, so draining on upgrade has no dependency on the bootstrapped cluster
ephemeral "talos_cluster_kubeconfig" "this" {
  cluster_name    = local.cluster_name
  machine_secrets = talos_machine_secrets.this.machine_secrets
  endpoint        = "https://${local.cluster_vip}:6443"
}

# One resource per node, chained so upgrades go one node at a time and etcd keeps quorum
resource "talos_machine" "cp_01" {
  depends_on = [module.k8s_cp_01]

  node                  = local.talos_nodes["k8s-cp-01"]
  client_configuration  = talos_machine_secrets.this.client_configuration
  machine_configuration = data.talos_machine_configuration.controlplane.machine_configuration
  image                 = data.talos_image_factory_urls.this.urls.installer
  kubeconfig_wo         = ephemeral.talos_cluster_kubeconfig.this.kubeconfig_raw

  ignore_kubernetes_upgrade_drift = true
}

resource "talos_machine" "cp_02" {
  depends_on = [module.k8s_cp_02, talos_machine.cp_01]

  node                  = local.talos_nodes["k8s-cp-02"]
  client_configuration  = talos_machine_secrets.this.client_configuration
  machine_configuration = data.talos_machine_configuration.controlplane.machine_configuration
  image                 = data.talos_image_factory_urls.this.urls.installer
  kubeconfig_wo         = ephemeral.talos_cluster_kubeconfig.this.kubeconfig_raw

  ignore_kubernetes_upgrade_drift = true
}

resource "talos_machine" "cp_03" {
  depends_on = [module.k8s_cp_03, talos_machine.cp_02]

  node                  = local.talos_nodes["k8s-cp-03"]
  client_configuration  = talos_machine_secrets.this.client_configuration
  machine_configuration = data.talos_machine_configuration.controlplane.machine_configuration
  image                 = data.talos_image_factory_urls.this.urls.installer
  kubeconfig_wo         = ephemeral.talos_cluster_kubeconfig.this.kubeconfig_raw

  ignore_kubernetes_upgrade_drift = true
}

resource "talos_cluster" "this" {
  depends_on = [talos_machine.cp_01, talos_machine.cp_02, talos_machine.cp_03]
  

  node                 = local.talos_nodes["k8s-cp-01"]
  control_plane_nodes  = values(local.talos_nodes)
  client_configuration = talos_machine_secrets.this.client_configuration
  kubernetes_version   = local.kubernetes_version
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_cluster.this]

  node                 = local.talos_nodes["k8s-cp-03"]
  client_configuration = talos_machine_secrets.this.client_configuration
}