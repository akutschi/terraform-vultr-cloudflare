# ====================
# Outputs
# ====================

output "instance_ids" {
  description = "Map of server name to Vultr instance ID"
  value       = { for name, instance in vultr_instance.vpn_instance : name => instance.id }
}

output "instance_ips_v4" {
  description = "Map of server name to main IPv4 address"
  value       = { for name, instance in vultr_instance.vpn_instance : name => instance.main_ip }
}

output "instance_ips_v6" {
  description = "Map of server name to main IPv6 address"
  value       = { for name, instance in vultr_instance.vpn_instance : name => instance.v6_main_ip }
}

output "instance_hostnames" {
  description = "Map of server name to hostname"
  value       = { for name, instance in vultr_instance.vpn_instance : name => instance.hostname }
}

output "firewall_group_id" {
  description = "ID of the Vultr firewall group"
  value       = vultr_firewall_group.vpn_firewallgroup.id
}
