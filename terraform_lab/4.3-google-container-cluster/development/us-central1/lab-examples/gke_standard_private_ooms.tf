locals {
  active = var.teardown ? false : true
  env_short = {
    "development"   = "dev",
    "nonproduction" = "stg",
    "production"    = "prd"
  }
  env_list           = toset(["dev"])
  env_code           = substr(var.environment, 0, 1)
  is_dev_bool        = var.environment == "development" ? true : false
  is_prd_bool        = var.environment == "production" ? true : false
  is_primary_region  = var.project_primary_region == var.region ? true : false
  is_primary_cluster = var.project_primary_region == var.region ? true : false
}

module "region_naming" {
  source  = "terraform-google-modules/utils/google"
  version = "~> 0.7"
}

module "naming" {
  source      = "app.terraform.io/flyrlabs/modules/flyr//modules/naming"
  version     = "0.8.0"
  environment = local.env_short[var.environment]
  region      = var.region
  instance    = var.instance_number
  name        = var.stack
  product     = var.stack
  stack       = var.stack
  tenant      = var.tenant
  owner       = "james_nguyen"
}

# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/private-cluster-update-variant
module "gke_standard_private" {
  for_each = {
    for subnet, meta in data.terraform_remote_state.google_region.outputs.network_subnets :
    subnet => meta
    if local.active &&
    meta.name == "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}" &&
    try(meta.secondary_ip_range, null) != null &&
    length(meta.secondary_ip_range) > 0
  }
  source                               = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster-update-variant"
  version                              = "~> 33.0"
  project_id                           = var.project_id
  name                                 = module.naming.container_cluster.name
  release_channel                      = var.release_channel
  cluster_resource_labels              = module.naming.tags
  regional                             = true
  region                               = var.region
  network                              = split("/networks/", each.value.network)[1]  # Example: "https://www.googleapis.com/compute/v1/projects/prj-lab-james-nguyen/global/networks/vpc-d-prj-lab-james-nguyen-float-base"
  subnetwork                           = each.value.name                             # Example: "sb-d-prj-lab-james-nguyen-usc1-1"
  ip_range_pods                        = each.value.secondary_ip_range[0].range_name # TODO: handle multiple secondary ranges deterministically
  ip_range_services                    = each.value.secondary_ip_range[1].range_name # TODO: handle multiple secondary ranges deterministically
  master_ipv4_cidr_block               = var.master_ipv4_cidr_block
  master_global_access_enabled         = false
  enable_private_nodes                 = true
  enable_private_endpoint              = false
  network_policy                       = false
  network_tags                         = var.network_tags
  horizontal_pod_autoscaling           = true
  enable_vertical_pod_autoscaling      = true
  default_max_pods_per_node            = 100
  filestore_csi_driver                 = false
  gcs_fuse_csi_driver                  = true
  gateway_api_channel                  = "CHANNEL_STANDARD"
  datapath_provider                    = "ADVANCED_DATAPATH"
  http_load_balancing                  = true
  monitoring_enable_managed_prometheus = false
  remove_default_node_pool             = true
  create_service_account               = true
  deletion_protection                  = false

  maintenance_start_time = "2023-07-04T03:00:00Z"
  maintenance_end_time   = "2023-07-04T15:00:00Z" # the end time is used for calculating duration.
  maintenance_recurrence = local.is_prd_bool ? "FREQ=WEEKLY;BYDAY=TH" : "FREQ=WEEKLY;BYDAY=TU"

  # security_posture_mode               = "BASIC"
  # security_posture_vulnerability_mode = "VULNERABILITY_BASIC"

  node_pools = [
    {
      name               = "small-spot-a"
      machine_type       = var.node_pool_instance_type
      node_locations     = "${var.project_region}-a"
      min_count          = var.min_pool_count
      max_count          = var.max_pool_count
      initial_node_count = var.min_pool_count
      # max_pods_per_node  = 32
      spot               = local.is_dev_bool
      # preemptible        = false
      local_ssd_count    = 0
      disk_size_gb       = 80
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = true
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
    },
    {
      name               = "small-spot-b"
      machine_type       = var.node_pool_instance_type
      node_locations     = "${var.project_region}-b"
      min_count          = var.min_pool_count
      max_count          = var.max_pool_count
      initial_node_count = var.min_pool_count
      # max_pods_per_node  = 32
      spot               = local.is_dev_bool
      # preemptible        = false
      local_ssd_count    = 0
      disk_size_gb       = 80
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = true
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
    },
    {
      name               = "small-spot-c"
      machine_type       = var.node_pool_instance_type
      node_locations     = "${var.project_region}-c"
      min_count          = var.min_pool_count
      max_count          = var.max_pool_count
      initial_node_count = var.min_pool_count
      # max_pods_per_node  = 32
      spot               = local.is_dev_bool
      # preemptible        = false
      local_ssd_count    = 0
      disk_size_gb       = 80
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = true
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
    },
    # {
    #   name               = "spot-a"
    #   machine_type       = var.node_pool_instance_type
    #   node_locations     = "${var.project_region}-a"
    #   min_count          = var.min_pool_count
    #   max_count          = var.max_pool_count
    #   local_ssd_count    = 0
    #   spot               = local.is_dev_bool
    #   disk_size_gb       = 80
    #   disk_type          = "pd-standard"
    #   image_type         = "COS_CONTAINERD"
    #   enable_gcfs        = true
    #   enable_gvnic       = false
    #   auto_repair        = true
    #   auto_upgrade       = true
    #   preemptible        = false
    #   initial_node_count = var.min_pool_count
    # },
    # {
    #   name               = "spot-b"
    #   machine_type       = var.node_pool_instance_type
    #   node_locations     = "${var.project_region}-b"
    #   min_count          = var.min_pool_count
    #   max_count          = var.max_pool_count
    #   local_ssd_count    = 0
    #   spot               = local.is_dev_bool
    #   disk_size_gb       = 80
    #   disk_type          = "pd-standard"
    #   image_type         = "COS_CONTAINERD"
    #   enable_gcfs        = true
    #   enable_gvnic       = false
    #   auto_repair        = true
    #   auto_upgrade       = true
    #   preemptible        = false
    #   initial_node_count = var.min_pool_count
    # },
    # {
    #   name               = "spot-c"
    #   machine_type       = var.node_pool_instance_type
    #   node_locations     = "${var.project_region}-c"
    #   min_count          = var.min_pool_count
    #   max_count          = var.max_pool_count
    #   local_ssd_count    = 0
    #   spot               = local.is_dev_bool
    #   disk_size_gb       = 80
    #   disk_type          = "pd-standard"
    #   image_type         = "COS_CONTAINERD"
    #   enable_gcfs        = true
    #   enable_gvnic       = false
    #   auto_repair        = true
    #   auto_upgrade       = true
    #   preemptible        = false
    #   initial_node_count = var.min_pool_count
    # },
  ]
  node_pools_oauth_scopes = {
    spot-a = [
      "https://www.googleapis.com/auth/cloud-platform",
    ],
    spot-b = [
      "https://www.googleapis.com/auth/cloud-platform",
    ],
    spot-c = [
      "https://www.googleapis.com/auth/cloud-platform",
    ],
  }
  node_pools_labels = {
    all = module.naming.tags
  }
}

#
# AKA as Hub
#

# https://cloud.google.com/kubernetes-engine/docs/how-to/enabling-multi-cluster-gateways#register_with
# module "fleet_membership" {
#   source       = "terraform-google-modules/kubernetes-engine/google//modules/fleet-membership"
#   version      = "31.1.0"
#   project_id   = var.project_id
#   cluster_name = module.gke.name
#   location     = module.gke.location
# }

# step 1 - https://cloud.google.com/kubernetes-engine/docs/how-to/enabling-multi-cluster-gateways#enable_multi-cluster_gateway_in_the_fleet
# resource "google_gke_hub_feature" "multiclusteringress" {
#   count    = var.config_cluster == true ? 1 : 0
#   name     = "multiclusteringress"
#   location = module.fleet_membership.location
#   spec {
#     multiclusteringress {
#       config_membership = "projects/${module.fleet_membership.project_id}/locations/${module.fleet_membership.location}/memberships/${module.fleet_membership.cluster_membership_id}"
#     }
#   }
# }

#
# Artifact Registry Container access for GKE Service Account
#

# module "gke_sa_docker_product_repository_prd" {
#   source        = "app.terraform.io/flyrlabs/modules/flyr//modules/shared_resource_accessor"
#   version       = "0.8.0"
#   accessor      = module.gke.service_account
#   environment   = "prd"
#   accessor_type = "USER"
#   resource      = "product_gar_docker_repository"
#   role          = "roles/artifactregistry.reader"
# }

# module "gke_sa_docker_product_repository" {
#   count         = local.is_not_prd_count
#   source        = "app.terraform.io/flyrlabs/modules/flyr//modules/shared_resource_accessor"
#   version       = "0.8.0"
#   accessor      = module.gke.service_account
#   environment   = var.environment
#   accessor_type = "USER"
#   resource      = "product_gar_docker_repository"
#   role          = "roles/artifactregistry.reader"
# }
