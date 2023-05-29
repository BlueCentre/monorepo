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
  source      = "app.terraform.io/example/modules/example//modules/naming"
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

# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master
# https://console.cloud.google.com/kubernetes/workload/overview?project=prj-lab-james-nguyen&supportedpurview=project
module "gke_autopilot_private" {
  for_each = {
    for subnet, meta in data.terraform_remote_state.google_region.outputs.network_subnets :
    subnet => meta
    if local.active &&
    meta.name == "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}" &&
    try(meta.secondary_ip_range, null) != null &&
    length(meta.secondary_ip_range) > 0
  }
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version                 = "~> 33.0"
  project_id              = var.project_id
  name                    = module.naming.container_cluster.name
  release_channel         = var.release_channel
  cluster_resource_labels = module.naming.tags
  regional                = true
  region                  = var.region
  network                 = split("/networks/", each.value.network)[1]  # Example: "https://www.googleapis.com/compute/v1/projects/prj-lab-james-nguyen/global/networks/vpc-d-prj-lab-james-nguyen-float-base"
  subnetwork              = each.value.name                             # Example: "sb-d-prj-lab-james-nguyen-usc1-1"
  ip_range_pods           = each.value.secondary_ip_range[0].range_name # TODO: handle multiple secondary ranges deterministically
  ip_range_services       = each.value.secondary_ip_range[1].range_name # TODO: handle multiple secondary ranges deterministically
  # master_authorized_networks = [
  #   {
  #     cidr_block   = data.terraform_remote_state.google_region.outputs.network_master_ipv4_cidr_block,
  #     display_name = "VPC"
  #   },
  # ]
  # master_ipv4_cidr_block          = var.master_ipv4_cidr_block
  master_global_access_enabled    = false
  enable_private_nodes            = true
  enable_private_endpoint         = false
  network_tags                    = var.network_tags
  horizontal_pod_autoscaling      = true
  enable_vertical_pod_autoscaling = true
  gcs_fuse_csi_driver             = true
  deletion_protection             = false
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
#   source        = "app.terraform.io/example/modules/example//modules/shared_resource_accessor"
#   version       = "0.8.0"
#   accessor      = module.gke.service_account
#   environment   = "prd"
#   accessor_type = "USER"
#   resource      = "product_gar_docker_repository"
#   role          = "roles/artifactregistry.reader"
# }

# module "gke_sa_docker_product_repository" {
#   count         = local.is_not_prd_count
#   source        = "app.terraform.io/example/modules/example//modules/shared_resource_accessor"
#   version       = "0.8.0"
#   accessor      = module.gke.service_account
#   environment   = var.environment
#   accessor_type = "USER"
#   resource      = "product_gar_docker_repository"
#   role          = "roles/artifactregistry.reader"
# }
