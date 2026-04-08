# ====================
# Variables
# ====================

# --------------------
# Vultr
# --------------------

variable "vultr_api_key" {
  description = "API key for Vultr"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of the SSH key stored in Vultr"
  type        = string
}

variable "servers" {
  description = "Map of servers to create, keyed by region code"
  type = map(object({
    region = string
    plan   = string
  }))
  default = {}
}

variable "os_name" {
  description = "Operating system name to use for all servers"
  type        = string
  default     = "Debian 13 x64 (trixie)"
}

variable "label" {
  description = "Labels to identify servers and services"
  type        = string
}

# --------------------
# Cloudflare
# --------------------

variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
  sensitive   = true
}

#variable "cloudflare_email" {
#  description = "The E-Mail address assigned to the Cloudflare account"
#  type        = string
#  sensitive   = true
#}

#variable "cloudflare_api_key" {
#  description = "API key for Cloudflare"
#  type        = string
#  sensitive   = true
#}

variable "subdomain" {
  description = "Sub-domain for server hostnames"
  type        = string
}

variable "domain" {
  description = "Base domain for server hostnames"
  type        = string
}

# --------------------
# Local  
# --------------------

variable "inventory_dir" {
  description = "Directory where inventory.ini will be written. Defaults to the module directory."
  type        = string
  default     = ""
}

