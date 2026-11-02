terraform {
  required_providers {
    netbird = {
      source = "registry.terraform.io/netbirdio/netbird"
      version = "0.0.11"
    }
  }
  # Run this to init. Only needed on first run or when changed.
  # `tofu init -backend-config=../garage.s3.tfbackend`
  backend "s3" {
    key = "netbird/terraform.tfstate"
  }
}

provider "netbird" {
  token = var.netbird_token_secret
}

# --- Groups ---
resource "netbird_group" "k8s_admin_peers" {
  name = "k8s-admin-peers"

  lifecycle {
    ignore_changes = [peers, resources]
  }
}

resource "netbird_group" "k8s_admin_resources" {
  name = "k8s-admin-resources"

  lifecycle {
    ignore_changes = [peers, resources]
  }
}

# --- DNS ---
resource "netbird_dns_zone" "admin" {
  name                = "admin-cobaltcavern"
  domain              = "admin.cobaltcavern.com"
  enabled             = true
  distribution_groups = [netbird_group.k8s_admin_peers.id]
}

resource "netbird_nameserver_group" "k8s_admin_dns" {
  name                   = "k8s-admin-dns"
  description            = "Quad9 for k8s-admin-peers"
  enabled                = true
  primary                = true
  domains                = []
  search_domains_enabled = false
  groups                 = [netbird_group.k8s_admin_peers.id]
  nameservers = [
    {
      ip      = "9.9.9.9"
      ns_type = "udp"
      port    = 53
    },
    {
      ip      = "149.112.112.112"
      ns_type = "udp"
      port    = 53
    }
  ]
}

# --- Access ---
resource "netbird_policy" "k8s_admin_access" {
  name        = "k8s-admin-peers to k8s-admin-resources"
  description = "Admin devices can reach the admin resources exposed by the NetBird operator"
  enabled     = true

  rule {
    name          = "http"
    action        = "accept"
    bidirectional = false
    protocol      = "tcp"
    ports         = ["80"]
    sources       = [netbird_group.k8s_admin_peers.id]
    destinations  = [netbird_group.k8s_admin_resources.id]
  }
}