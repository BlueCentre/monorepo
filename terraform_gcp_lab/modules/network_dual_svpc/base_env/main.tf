locals {
  bgp_asn_number = var.enable_partner_interconnect ? "16550" : "64514"
}

/******************************************
 Base shared VPC
*****************************************/

module "base_shared_vpc" {
  source = "../base_shared_vpc"

  project_id                 = local.base_project_id
  # dns_hub_project_id         = local.dns_hub_project_id
  environment_code           = var.environment_code
  private_service_cidr       = var.base_private_service_cidr
  private_service_connect_ip = var.base_private_service_connect_ip
  default_region1            = var.default_region1
  default_region2            = var.default_region2
  # domain                     = var.domain
  bgp_asn_subnet             = local.bgp_asn_number

  subnets = [
    {
      subnet_name                      = "sb-${var.environment_code}-shared-base-${var.default_region1}"
      subnet_ip                        = var.base_subnet_primary_ranges[var.default_region1]
      subnet_region                    = var.default_region1
      subnet_private_access            = "true"
      subnet_flow_logs                 = true
      subnet_flow_logs_interval        = var.base_vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.base_vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.base_vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.base_vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.base_vpc_flow_logs.filter_expr
      description                      = "First ${var.env} subnet example."
    },
    {
      subnet_name                      = "sb-${var.environment_code}-shared-base-${var.default_region2}"
      subnet_ip                        = var.base_subnet_primary_ranges[var.default_region2]
      subnet_region                    = var.default_region2
      subnet_private_access            = "true"
      subnet_flow_logs                 = true
      subnet_flow_logs_interval        = var.base_vpc_flow_logs.aggregation_interval
      subnet_flow_logs_sampling        = var.base_vpc_flow_logs.flow_sampling
      subnet_flow_logs_metadata        = var.base_vpc_flow_logs.metadata
      subnet_flow_logs_metadata_fields = var.base_vpc_flow_logs.metadata_fields
      subnet_flow_logs_filter          = var.base_vpc_flow_logs.filter_expr
      description                      = "Second ${var.env} subnet example."
    },
    {
      subnet_name      = "sb-${var.environment_code}-shared-base-${var.default_region1}-proxy"
      subnet_ip        = var.base_subnet_proxy_ranges[var.default_region1]
      subnet_region    = var.default_region1
      subnet_flow_logs = false
      description      = "First ${var.env} proxy-only subnet example."
      role             = "ACTIVE"
      purpose          = "REGIONAL_MANAGED_PROXY"
    },
    {
      subnet_name      = "sb-${var.environment_code}-shared-base-${var.default_region2}-proxy"
      subnet_ip        = var.base_subnet_proxy_ranges[var.default_region2]
      subnet_region    = var.default_region2
      subnet_flow_logs = false
      description      = "Second ${var.env} proxy-only subnet example."
      role             = "ACTIVE"
      purpose          = "REGIONAL_MANAGED_PROXY"
    }
  ]
  secondary_ranges = {
    "sb-${var.environment_code}-shared-base-${var.default_region1}" = var.base_subnet_secondary_ranges[var.default_region1]
  }
}
