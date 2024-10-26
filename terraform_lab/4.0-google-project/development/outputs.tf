#
# Remote state outputs
#

output "base_host_project_id" {
  description = "Base host project ID"
  value       = try(data.terraform_remote_state.networks.outputs.base_host_project_id, null)
}

output "base_network_name" {
  description = "Name of the VPC in the base host project"
  value       = try(data.terraform_remote_state.networks.outputs.base_network_name, null)
}

output "base_network_self_link" {
  description = "URI of the VPC in the base host project"
  value       = try(data.terraform_remote_state.networks.outputs.base_network_self_link, null)
}


#
# Project outputs
#

# output "project_network" {
#   value = try(module.vpc[0].network, null)
# }

output "project_network_id" {
  description = "Network ID for the project"
  value       = try(module.vpc[0].network_id, null)
}

output "project_network_name" {
  description = "Network name for the project"
  value       = try(module.vpc[0].network_name, null)
}

output "project_network_self_link" {
  description = "Network self link for the project"
  value       = try(module.vpc[0].network_self_link, null)
}

output "iap_client_id" {
  description = "The IAP client ID for the project"
  value       = google_iap_client.project_client.client_id
}

output "iap_client_secret" {
  description = "The IAP client secret for the project"
  value       = google_iap_client.project_client.secret
  sensitive   = true
}

output "project_service_accounts_map" {
  description = "The service accounts map for the project used by other modules/workspaces"
  value       = module.service_accounts.service_accounts_map
}
