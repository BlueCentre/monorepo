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

# module "naming" {
#   source      = "app.terraform.io/example/modules/example//modules/naming"
#   version     = "0.8.0"
#   environment = local.env_short[var.environment]
#   region      = var.region
#   name        = var.stack
#   product     = var.stack
#   stack       = var.stack
#   tenant      = var.tenant
#   owner       = "james_nguyen"
# }

# https://console.cloud.google.com/kubernetes/workload/overview?project=prj-lab-james-nguyen&supportedpurview=project

# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/auth
# module "gke_auth" {
#   source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
#   version      = "~> 33.0"
#   project_id   = var.project_id
#   cluster_name = data.terraform_remote_state.google_container_cluster.outputs.gke_cluster_name
#   location     = var.region
#   # use_private_endpoint = true
# }

# resource "local_file" "kubeconfig" {
#   content  = module.gke_auth.kubeconfig_raw
#   filename = "${path.module}/.kubeconfig"
# }
