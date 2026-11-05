variable "netbird_token_secret" {
  description = "The API Token Secret for netbird."
  type        = string
  sensitive   = true
}

variable "home_local_domains" {
  description = "The home domains."
  type        = list(string)
}

variable "home_dns_server" {
  description = "Resolver that answers the home domain."
  type        = string
}