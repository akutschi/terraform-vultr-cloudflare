# ====================
# Data
# ====================

# --------------------
# Vultr
# --------------------

data "vultr_ssh_key" "ssh_key" {
  filter {
    name   = "name"
    values = [var.ssh_key_name]
  }
}

data "vultr_os" "os" {
  filter {
    name   = "name"
    values = [var.os_name]
  }
}

# --------------------
# Cloudflare
# --------------------

data "cloudflare_zone" "domain" {
  filter = { name = "${var.domain}" }
}
