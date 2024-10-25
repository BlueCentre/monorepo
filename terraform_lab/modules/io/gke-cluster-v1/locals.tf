locals {
  terraform_user = "terraform"

  # Take first non-null value of `region` and `zone` as the location
  location = coalesce(var.region, var.zone)

  # Reset `zone` to `null` if `region` is non-null
  zone = var.region == null ? var.zone : null

  # When removing the default node pool and using a `google_container_node_pool`
  # (which is encoded in the `gke-node-pool` module), it is recommended to set
  # `remove_default_node_pool` to `true` and to set `initial_node_count` to `1`
  # See https://www.terraform.io/docs/providers/google/r/container_cluster.html#remove_default_node_pool
  remove_default_node_pool = true
  initial_node_count       = 1

  # Set the type for labels
  type = local.zone == null ? "REGIONAL" : "ZONAL"

  # Nullify the values of these variables if `vpc_network_self_link` is unset
  subnetwork_self_link          = var.vpc_network_self_link == null ? null : var.vpc_subnetwork_self_link
  default_max_pods_per_node     = var.vpc_network_self_link == null ? null : var.default_max_pods_per_node
  cluster_ipv4_cidr_block       = var.vpc_network_self_link == null ? null : var.use_shared_network ? null : var.cluster_ipv4_cidr_block
  services_ipv4_cidr_block      = var.vpc_network_self_link == null ? null : var.use_shared_network ? null : var.services_ipv4_cidr_block
  cluster_secondary_range_name  = var.vpc_network_self_link == null ? null : var.cluster_secondary_range_name
  services_secondary_range_name = var.vpc_network_self_link == null ? null : var.services_secondary_range_name

  # Set a placeholder variable as a list for determining whether to render the `ip_allocation_policy` block
  # If `vpc_network_self_link` is set, the list gets a length of 1, otherwise, the list is empty
  ip_allocation_policy = var.vpc_network_self_link == null ? [] : [true]

  environment               = var.environment == null ? null : lower(replace(var.environment, " ", "-"))
  owner                     = lower(replace(var.owner, " ", "-"))
  team                      = lower(coalesce(var.team, local.owner))
  workload_identity_enabled = var.workload_identity_enabled == true ? [true] : []
  filestore_csi_enabled     = var.filestore_csi_enabled == true ? [true] : []

  default_labels = {
    deployed_by      = local.terraform_user
    environment      = local.environment
    owner            = local.owner
    region           = var.region
    zone             = local.zone
    type             = local.type
    flyr_owner       = local.owner
    flyr_team        = local.team
    flyr_environment = local.environment
  }

  # Have custom labels be overwritten by predefined labels
  labels = merge(
    { for key, value in var.custom_labels : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) },
    { for key, value in local.default_labels : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) if value != null },
  )
}
