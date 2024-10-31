# output "DEBUG" {
#   value = data.terraform_remote_state.google_region.outputs.network_subnets["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"]
# }


# output "gke_service_account" {
#   value     = try(module.gke_autopilot_public["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].service_account, null)
# }

# output "gke_identity_service_enabled" {
#   value     = try(module.gke_autopilot_public["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].identity_service_enabled, null)
# }

# output "gke_identity_namespace" {
#   value     = try(module.gke_autopilot_public["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].identity_namespace, null)
# }

# output "gke_cluster_id" {
#   value     = try(module.gke_autopilot_public["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].cluster_id, null)
# }

# output "gke_cluster_name" {
#   value     = try(module.gke_autopilot_public["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].name, null)
# }

# output "gke_endpoint" {
#   value     = try(module.gke_autopilot_public["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].endpoint, null)
#   sensitive = true
# }


output "gke_service_account" {
  value     = try(module.gke_autopilot_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].service_account, null)
}

output "gke_identity_service_enabled" {
  value     = try(module.gke_autopilot_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].identity_service_enabled, null)
}

output "gke_identity_namespace" {
  value     = try(module.gke_autopilot_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].identity_namespace, null)
}

output "gke_cluster_id" {
  value     = try(module.gke_autopilot_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].cluster_id, null)
}

output "gke_cluster_name" {
  value     = try(module.gke_autopilot_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].name, null)
}

output "gke_endpoint" {
  value     = try(module.gke_autopilot_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].endpoint, null)
  sensitive = true
}


# output "gke_service_account" {
#   value     = try(module.gke_standard_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].service_account, null)
# }

# output "gke_identity_service_enabled" {
#   value     = try(module.gke_standard_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].identity_service_enabled, null)
# }

# output "gke_identity_namespace" {
#   value     = try(module.gke_standard_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].identity_namespace, null)
# }

# output "gke_cluster_id" {
#   value     = try(module.gke_standard_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].cluster_id, null)
# }

# output "gke_cluster_name" {
#   value     = try(module.gke_standard_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].name, null)
# }

# output "gke_endpoint" {
#   value     = try(module.gke_standard_private["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].endpoint, null)
#   sensitive = true
# }
