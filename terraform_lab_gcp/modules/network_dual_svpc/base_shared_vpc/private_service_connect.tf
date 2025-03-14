module "private_service_connect" {
  source  = "terraform-google-modules/network/google//modules/private-service-connect"
  version = "~> 9.1"

  project_id                 = var.project_id
  dns_code                   = "dz-${var.environment_code}-shared-base"
  network_self_link          = module.main.network_self_link
  private_service_connect_ip = var.private_service_connect_ip
  forwarding_rule_target     = "all-apis"
  service_directory_region   = var.default_region1
}
