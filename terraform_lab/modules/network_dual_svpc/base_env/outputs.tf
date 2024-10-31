/******************************************
 Private Outputs
*****************************************/

output "base_host_project_id" {
  value       = local.base_project_id
  description = "The base host project ID"
}

output "base_network_name" {
  value       = module.base_shared_vpc.network_name
  description = "The name of the VPC being created"
}

output "base_network_self_link" {
  value       = module.base_shared_vpc.network_self_link
  description = "The URI of the VPC being created"
}

output "base_subnets_names" {
  value       = module.base_shared_vpc.subnets_names
  description = "The names of the subnets being created"
}

output "base_subnets_ips" {
  value       = module.base_shared_vpc.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "base_subnets_self_links" {
  value       = module.base_shared_vpc.subnets_self_links
  description = "The self-links of subnets being created"
}

output "base_subnets_secondary_ranges" {
  value       = module.base_shared_vpc.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}
