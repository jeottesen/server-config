variable "state_encryption_passphrase" {
  description = "Passphrase for OpenTofu state and plan encryption"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.state_encryption_passphrase) >= 16
    error_message = "Passphrase must be at least 16 characters."
  }
}