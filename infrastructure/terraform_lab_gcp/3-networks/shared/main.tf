locals {
  env                = "common"
  environment_code   = "c"
  bgp_asn_number     = var.enable_partner_interconnect ? "16550" : "64514"
  dns_bgp_asn_number = var.enable_partner_interconnect ? "16550" : var.bgp_asn_dns

  # dedicated_interconnect_egress_policy = var.enable_dedicated_interconnect ? [
  #   {
  #     "from" = {
  #       "identity_type" = ""
  #       "identities"    = ["serviceAccount:${local.networks_service_account}"]
  #     },
  #     "to" = {
  #       "resources" = ["projects/${local.interconnect_project_number}"]
  #       "operations" = {
  #         "compute.googleapis.com" = {
  #           "methods" = ["*"]
  #         }
  #       }
  #     }
  #   },
  # ] : []
}
