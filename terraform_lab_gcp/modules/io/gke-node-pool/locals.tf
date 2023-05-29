locals {
  terraform_user = "terraform"

  disk_type           = lower("pd-${var.disk_type}")
  custom_machine_type = var.num_cpus == null || var.memory_size_mb == null ? null : "custom-${var.num_cpus}-${var.memory_size_mb}"
  machine_type        = coalesce(local.custom_machine_type, var.machine_type)
  image_type          = upper(var.image_type)

  # Only set these if both are set
  autoscaling_min_size = var.autoscaling_min_size == null || var.autoscaling_max_size == null ? null : var.autoscaling_min_size
  autoscaling_max_size = var.autoscaling_min_size == null || var.autoscaling_max_size == null ? null : var.autoscaling_max_size

  # Use array with a single value for `autoscaling_config_array` so that we can use
  # the `dynamic` terraform built-in and only render the block in the autoscaling
  # is desired
  autoscaling_config_array = (
    local.autoscaling_min_size == null || local.autoscaling_max_size == null ?
    [] :
    [{
      autoscaling_min_size = local.autoscaling_min_size,
      autoscaling_max_size = local.autoscaling_max_size
    }]
  )


  default_metadata = {
    disable-legacy-endpoints = true
  }

  # Have custom metadata overwrite predefined metadata
  metadata = merge(
    { for key, value in local.default_metadata : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) },
    { for key, value in var.metadata : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) if value != null },
  )

  oauth_scopes = compact([
    var.oauth_scope_gcloud ? "cloud-platform" : "",
    var.oauth_scope_storage_read_only ? "storage-ro" : "",
    var.oauth_scope_logging_write ? "logging-write" : "",
    var.oauth_scope_monitoring ? "monitoring" : ""
  ])

  environment               = var.environment == null ? null : lower(replace(var.environment, " ", "-"))
  owner                     = lower(replace(var.owner, " ", "-"))
  team                      = lower(coalesce(var.team, local.owner))
  workload_metadata_config  = var.workload_identity_enabled == true ? "GKE_METADATA" : "GCE_METADATA"
  workload_identity_enabled = var.workload_identity_enabled == true ? [true] : []

  default_labels = {
    deployed_by      = local.terraform_user
    environment      = local.environment
    owner            = local.owner
    preemptible      = var.preemptible
    example_owner       = local.owner
    example_team        = local.team
    example_environment = local.environment
  }

  # Have custom labels be overwritten by predefined labels
  labels = merge(
    { for key, value in var.custom_labels : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) },
    { for key, value in local.default_labels : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) if value != null },
  )
}
