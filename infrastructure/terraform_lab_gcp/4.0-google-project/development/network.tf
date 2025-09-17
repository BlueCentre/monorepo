# chrome://bookmarks/?id=5910
# https://console.cloud.google.com/networking/networks/list?project=prj-lab-james-nguyen&supportedpurview=project&pageTab=CURRENT_PROJECT_NETWORKS
# https://github.com/terraform-google-modules/terraform-google-network/tree/master/modules/vpc
module "vpc" {
  # for_each     = local.env_list # terraform state mv 'module.vpc[0].google_compute_network.network' 'module.vpc["dev"].google_compute_network.network'
  count        = local.active ? 1 : 0
  source       = "terraform-google-modules/network/google//modules/vpc"
  version      = "~> 9.1"
  project_id   = var.project_id
  network_name = "vpc-${local.env_code}-${var.project_id}-float-base"
  routing_mode = "GLOBAL"
  description  = "Terraform managed VPC: google-project"
}

#***************************************************************
#  Configure Service Networking for Cloud SQL & future services.
#***************************************************************

# https://cloud.google.com/sql/docs/mysql/configure-private-services-access#terraform
# https://console.cloud.google.com/networking/networks/details/vpc-d-prj-lab-james-nguyen-float-base?project=prj-lab-james-nguyen&supportedpurview=project&pageTab=PRIVATE_SERVICES_ACCESS
resource "google_compute_global_address" "private_service_access_address" {
  count         = local.active && var.private_service_cidr != null ? 1 : 0
  # name          = "ga-${module.vpc[0].network_name}-vpc-peering-internal" # "ga-${local.vpc_name}-vpc-peering-internal"
  name          = "ga-prj-lab-float-base-vpc-peering-internal" # "ga-${local.vpc_name}-vpc-peering-internal"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.private_service_cidr == null ? var.private_service_cidr : element(split("/", var.private_service_cidr), 0)
  prefix_length = var.private_service_cidr == null ? var.prefix_length : element(split("/", var.private_service_cidr), 1)
  network       = module.vpc[0].network_self_link
}

# https://cloud.google.com/sql/docs/mysql/configure-private-services-access#create_a_private_connection
# https://console.cloud.google.com/networking/networks/details/vpc-d-prj-lab-james-nguyen-float-base?project=prj-lab-james-nguyen&supportedpurview=project&pageTab=PEERINGS
resource "google_service_networking_connection" "private_vpc_connection" {
  count                   = local.active && var.private_service_cidr != null ? 1 : 0
  network                 = module.vpc[0].network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access_address[0].name]
}

# Firewall

# IP: https://docs.google.com/spreadsheets/d/17TxvIHJZaD5eT4orMh_E6i3kYRnIf_Ov_F_o7px3IPo/edit?gid=227110309#gid=227110309

# Firewall: https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges
