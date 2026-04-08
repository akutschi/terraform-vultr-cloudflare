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

resource "vultr_firewall_group" "vpn_firewallgroup" {
  description = "wireguard firewall"
}

resource "vultr_firewall_rule" "ssh_v4" {
  firewall_group_id = vultr_firewall_group.vpn_firewallgroup.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "22"
}

resource "vultr_firewall_rule" "ssh_v6" {
  firewall_group_id = vultr_firewall_group.vpn_firewallgroup.id
  protocol          = "tcp"
  ip_type           = "v6"
  subnet            = "::"
  subnet_size       = 0
  port              = "22"
}

resource "vultr_firewall_rule" "wireguard_v4" {
  firewall_group_id = vultr_firewall_group.vpn_firewallgroup.id
  protocol          = "udp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "51820"
}

resource "vultr_firewall_rule" "wireguard_v6" {
  firewall_group_id = vultr_firewall_group.vpn_firewallgroup.id
  protocol          = "udp"
  ip_type           = "v6"
  subnet            = "::"
  subnet_size       = 0
  port              = "51820"
}

# -----------------------------------------------
# Create Server Instance
# -----------------------------------------------

resource "vultr_instance" "vpn_instance" {
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
  firewall_group_id = vultr_firewall_group.vpn_firewallgroup.id
}

# -----------------------------------------------
# Create Cloudflare Name Server Entries
# -----------------------------------------------

resource "cloudflare_dns_record" "ardathon_server_v4" {
  for_each = var.servers

  zone_id = data.cloudflare_zone.domain.zone_id
  name    = "${each.key}.${var.subdomain}"
  content = vultr_instance.vpn_instance[each.key].main_ip
  type    = "A"
  proxied = false
  ttl     = 1
  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "ardathon_server_v6" {
  for_each = var.servers

  zone_id = data.cloudflare_zone.domain.zone_id
  name    = "${each.key}.${var.subdomain}"
  content = vultr_instance.vpn_instance[each.key].v6_main_ip
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
    instances = {
      for name, instance in vultr_instance.vpn_instance : name => {
        hostname = instance.hostname
      }
    }
  })
  filename = "${path.module}/inventory.ini"
}
