/******************************************
  Mandatory and optional firewall rules
 *****************************************/

module "firewall_rules" {
  source      = "terraform-google-modules/network/google//modules/network-firewall-policy"
  version     = "~> 9.0"
  project_id  = var.project_id
  policy_name = "fp-${var.environment_code}-hub-and-spoke-base-firewalls"
  description = "Firewall rules for base hub and spoke shared vpc: ${module.main.network_name}."
  target_vpcs = ["projects/${var.project_id}/global/networks/${module.main.network_name}"]

  rules = concat(
    [
      {
        priority       = "65530"
        direction      = "EGRESS"
        action         = "deny"
        rule_name      = "fw-${var.environment_code}-shared-base-65530-e-d-all-all-all"
        description    = "Lower priority rule to deny all egress traffic."
        enable_logging = var.firewall_enable_logging
        match = {
          dest_ip_ranges = ["0.0.0.0/0"]
          layer4_configs = [
            {
              ip_protocol = "all"
            },
          ]
        }
      },
      {
        priority       = "1000"
        direction      = "EGRESS"
        action         = "allow"
        rule_name      = "fw-${var.environment_code}-shared-base-1000-e-a-allow-google-apis-all-tcp-443"
        description    = "Lower priority rule to allow private google apis on TCP port 443."
        enable_logging = var.firewall_enable_logging
        match = {
          dest_ip_ranges = [local.private_googleapis_cidr]
          layer4_configs = [
            {
              ip_protocol = "tcp"
              ports       = ["443"]
            },
          ]
        }
      }
    ],
    !var.enable_all_vpc_internal_traffic ? [] : [
      {
        priority       = "10000"
        direction      = "EGRESS"
        action         = "allow"
        rule_name      = "fw-${var.environment_code}-shared-base-10000-e-a-all-all-all"
        description    = "Allow all egress to the provided IP range."
        enable_logging = var.firewall_enable_logging
        match = {
          dest_ip_ranges = module.main.subnets_ips
          layer4_configs = [
            {
              ip_protocol = "all"
            },
          ]
        }
      }
    ],
    !var.enable_all_vpc_internal_traffic ? [] : [
      {
        priority       = "10001"
        direction      = "INGRESS"
        action         = "allow"
        rule_name      = "fw-${var.environment_code}-shared-base-10001-i-a-all"
        description    = "Allow all ingress to the provided IP range."
        enable_logging = var.firewall_enable_logging
        match = {
          src_ip_ranges = module.main.subnets_ips
          layer4_configs = [
            {
              ip_protocol = "all"
            },
          ]
        }
      }
    ]
  )
}
