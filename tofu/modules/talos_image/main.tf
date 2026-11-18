terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
  }
}

locals {
  talos_version = "v1.14.5"
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = local.talos_version
  filters = {
    names = [
      "qemu-guest-agent",
      "iscsi-tools",
      "util-linux-tools",
      "i915",
      "netbird",
      "nvidia-open-gpu-kernel-modules-lts",
      "nvidia-container-toolkit-lts",
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
      }
    }
  })
}

data "talos_image_factory_urls" "this" {
  talos_version     = local.talos_version
  schematic_id      = talos_image_factory_schematic.this.id
  platform          = "nocloud"
  disk_image_format = "qcow2"
}