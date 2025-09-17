#
# Remote state outputs
#

output "base_subnets_names" {
  description = "The names of the subnets being created"
  value       = try(data.terraform_remote_state.networks.outputs.base_subnets_names, null)
}

output "base_subnets_ips" {
  description = "The IPs and CIDRs of the subnets being created"
  value       = try(data.terraform_remote_state.networks.outputs.base_subnets_ips, null)
}

output "base_subnets_self_links" {
  description = "The self-links of subnets being created"
  value       = try(data.terraform_remote_state.networks.outputs.base_subnets_self_links, null)
}

output "base_subnets_secondary_ranges" {
  description = "The secondary ranges associated with these subnets"
  value       = try(data.terraform_remote_state.networks.outputs.base_subnets_secondary_ranges, null)
}


#
# Project outputs
#

output "network_id" {
  description = "Project network ID"
  value       = try(local.network_id, null)
}

output "network_name" {
  description = "Project network name"
  value       = try(local.network_name, null)
}

output "network_self_link" {
  description = "Project network self link"
  value       = try(local.project_network_self_link, null)
}

output "network_subnets" {
  description = "Project network subnets"
  value       = try(module.vpc_subnet[0].subnets, null)
}

output "network_master_ipv4_cidr_block" {
  description = "Project network master ipv4 cidr block"
  value       = var.master_ipv4_cidr_block
}
