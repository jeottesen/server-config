terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.12.0"
    }
  }
  # Run this to init. Only needed on first run or when changed.
  # `tofu init -backend-config=../garage.s3.tfbackend`
  backend "s3" {
    key = "talos/terraform.tfstate"
  }
  encryption {
    key_provider "pbkdf2" "main" {
      passphrase = var.state_encryption_passphrase
    }

    method "aes_gcm" "main" {
      keys = key_provider.pbkdf2.main
    }

    state {
      method   = method.aes_gcm.main
      enforced = true
    }

    plan {
      method = method.aes_gcm.main
    }
  }
}