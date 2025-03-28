locals {
  env              = "development"
  environment_code = substr(local.env, 0, 1)
  /*
   * Base network ranges
   */
  base_private_service_cidr = "10.16.8.0/21"
  base_subnet_primary_ranges = {
    (local.default_region1) = "10.0.64.0/18"
    (local.default_region2) = "10.1.64.0/18"
  }
  base_subnet_proxy_ranges = {
    (local.default_region1) = "10.18.2.0/23"
    (local.default_region2) = "10.19.2.0/23"
  }
  base_subnet_secondary_ranges = {
    (local.default_region1) = [
      {
        range_name    = "rn-${local.environment_code}-shared-base-${local.default_region1}-gke-pod"
        ip_cidr_range = "100.64.64.0/18"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-base-${local.default_region1}-gke-svc"
        ip_cidr_range = "100.65.64.0/18"
      }
    ]
  }
  /*
   * Restricted network ranges
   */
  # restricted_private_service_cidr = "10.16.40.0/21"
  # restricted_subnet_primary_ranges = {
  #   (local.default_region1) = "10.8.64.0/18"
  #   (local.default_region2) = "10.9.64.0/18"
  # }
  # restricted_subnet_proxy_ranges = {
  #   (local.default_region1) = "10.26.2.0/23"
  #   (local.default_region2) = "10.27.2.0/23"
  # }
  # restricted_subnet_secondary_ranges = {
  #   (local.default_region1) = [
  #     {
  #       range_name    = "rn-${local.environment_code}-shared-restricted-${local.default_region1}-gke-pod"
  #       ip_cidr_range = "100.72.64.0/18"
  #     },
  #     {
  #       range_name    = "rn-${local.environment_code}-shared-restricted-${local.default_region1}-gke-svc"
  #       ip_cidr_range = "100.73.64.0/18"
  #     }
  #   ]
  # }
}

module "base_env" {
  # source = "../../modules/network_dual_svpc/base_env"
  source = "../../modules/network_hub_and_spoke/base_env"

  env                                   = local.env
  environment_code                      = local.environment_code
  # access_context_manager_policy_id      = var.access_context_manager_policy_id
  # perimeter_additional_members          = var.perimeter_additional_members
  # perimeter_additional_members_dry_run  = var.perimeter_additional_members_dry_run
  default_region1                       = local.default_region1
  default_region2                       = local.default_region2
  # domain                                = var.domain
  ingress_policies                      = var.ingress_policies
  ingress_policies_dry_run              = var.ingress_policies_dry_run
  egress_policies                       = var.egress_policies
  egress_policies_dry_run               = var.egress_policies_dry_run
  enable_partner_interconnect           = false
  base_private_service_cidr             = local.base_private_service_cidr
  base_subnet_primary_ranges            = local.base_subnet_primary_ranges
  base_subnet_proxy_ranges              = local.base_subnet_proxy_ranges
  base_subnet_secondary_ranges          = local.base_subnet_secondary_ranges
  base_private_service_connect_ip       = "10.17.0.2"
  # restricted_private_service_cidr       = local.restricted_private_service_cidr
  # restricted_subnet_primary_ranges      = local.restricted_subnet_primary_ranges
  # restricted_subnet_proxy_ranges        = local.restricted_subnet_proxy_ranges
  # restricted_subnet_secondary_ranges    = local.restricted_subnet_secondary_ranges
  # restricted_private_service_connect_ip = "10.17.0.6"
  remote_state_bucket                   = var.remote_state_bucket
  # tfc_org_name                          = var.tfc_org_name
}
