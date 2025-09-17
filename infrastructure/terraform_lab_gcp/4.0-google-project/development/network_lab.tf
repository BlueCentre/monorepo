locals {
  test = false
}

# Lab practice

module "vpc_test" {
  count        = local.test ? 1 : 0
  source       = "terraform-google-modules/network/google"
  version      = "~> 9.1"
  project_id   = var.project_id
  network_name = "vpc-${local.env_code}-${var.project_id}-test"
  routing_mode = "GLOBAL"
  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = "us-west1"
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "us-west1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This subnet has a description"
    },
  ]
}

# output "network_name" {
#   value = try(module.vpc_test[0].network_name, "No network name")
# }

# output "subnet_id" {
#   value = try(module.vpc_test[0].subnets["us-west1/subnet-01"].id, "No subnet id")
# }

# 1. create these modules first
# 2. terraform state mv 'module.vpc_test[0].module.vpc.google_compute_network.network' 'module.vpc_import[0].google_compute_network.network'
# 3. terraform state mv 'module.vpc_test[0].module.subnets.google_compute_subnetwork.subnetwork["us-west1/subnet-01"]' 'module.subnet_import[0].google_compute_subnetwork.subnetwork["us-west1/subnet-01"]'
# 4. terraform state mv 'module.vpc_test[0].module.subnets.google_compute_subnetwork.subnetwork["us-west1/subnet-02"]' 'module.subnet_import[0].google_compute_subnetwork.subnetwork["us-west1/subnet-02"]'

# module "vpc_import" {
#   count        = local.test ? 1 : 0
#   source       = "terraform-google-modules/network/google//modules/vpc"
#   version      = "~> 9.1"
#   project_id   = var.project_id
#   network_name = "vpc-${local.env_code}-${var.project_id}-test"
#   routing_mode = "GLOBAL"
# }

# module "subnet_import" {
#   count        = local.test ? 1 : 0
#   source       = "terraform-google-modules/network/google//modules/subnets"
#   version      = "~> 9.1"
#   project_id   = var.project_id
#   network_name = "vpc-${local.env_code}-${var.project_id}-test"
#   subnets = [
#     {
#       subnet_name           = "subnet-01"
#       subnet_ip             = "10.10.10.0/24"
#       subnet_region         = "us-west1"
#     },
#     {
#       subnet_name           = "subnet-02"
#       subnet_ip             = "10.10.20.0/24"
#       subnet_region         = "us-west1"
#       subnet_private_access = "true"
#       subnet_flow_logs      = "true"
#       description           = "This subnet has a description"
#     },
#   ]
# }

# output "network_name" {
#   value = try(module.vpc_import[0].network_name, "No network name")
# }

# output "subnet_id" {
#   value = try(module.subnet_import[0].subnets["us-west1/subnet-01"].id, "No subnet id")
# }
