terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2"
    }
  }
}

# ===============================================
# Resources
# ===============================================

# -----------------------------------------------
# Create Firewall Group and Rules
# -----------------------------------------------

resource "vultr_firewall_group" "firewallgroup" {
  description = var.label
}

resource "vultr_firewall_rule" "rule_v4" {
  for_each = var.firewall_group_rules

  firewall_group_id = vultr_firewall_group.firewallgroup.id
  protocol          = each.value.protocol
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = each.value.port
  source            = "0.0.0.0/0"
}

resource "vultr_firewall_rule" "rule_v6" {
  for_each = var.firewall_group_rules

  firewall_group_id = vultr_firewall_group.firewallgroup.id
  protocol          = each.value.protocol
  ip_type           = "v6"
  subnet            = "::"
  subnet_size       = 0
  port              = each.value.port
  source            = "::/0"
}

# -----------------------------------------------
# Create Server Instance
# -----------------------------------------------

resource "vultr_instance" "server_instance" {
  for_each = var.servers

  region = each.value.region
  plan   = each.value.plan

  os_id             = data.vultr_os.os.id
  enable_ipv6       = true
  backups           = "disabled"
  ddos_protection   = false
  activation_email  = false
  hostname          = "${each.key}.${var.subdomain}.${var.domain}"
  ssh_key_ids       = [data.vultr_ssh_key.ssh_key.id]
  label             = var.label
  tags              = ["terraform"]
  firewall_group_id = vultr_firewall_group.firewallgroup.id
}

# -----------------------------------------------
# Create Cloudflare Name Server Entries
# -----------------------------------------------

resource "cloudflare_dns_record" "dns_record_v4" {
  for_each = var.servers

  zone_id = data.cloudflare_zone.domain.zone_id
  name    = "${each.key}.${var.subdomain}"
  content = vultr_instance.server_instance[each.key].main_ip
  type    = "A"
  proxied = false
  ttl     = 1
  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "dns_record_v6" {
  for_each = var.servers

  zone_id = data.cloudflare_zone.domain.zone_id
  name    = "${each.key}.${var.subdomain}"
  content = vultr_instance.server_instance[each.key].v6_main_ip
  type    = "AAAA"
  proxied = false
  ttl     = 1
  comment = "Managed by Terraform"
}

# -----------------------------------------------
# Create Inventory for Ansible
# -----------------------------------------------

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    label = var.label
    instances = {
      for name, instance in vultr_instance.server_instance : name => {
        hostname = instance.hostname
      }
    }
  })
  filename = "${var.inventory_dir != "" ? var.inventory_dir : path.module}/inventory.ini"
}
