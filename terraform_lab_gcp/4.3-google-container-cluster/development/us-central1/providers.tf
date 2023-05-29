provider "google" {
  project = var.project_id   # "prj-lab-james-nguyen"
  region  = var.region       # "us-central1"
  zone    = var.project_zone # "us-central1-f"
}

# google_client_config and kubernetes provider must be explicitly specified like the following.
# data "google_client_config" "default" {}

# provider "kubernetes" {
#   host                   = "https://${module.gke_autopilot_public["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].endpoint}"
#   cluster_ca_certificate = base64decode(module.gke_autopilot_public["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].ca_certificate)
#   token                  = data.google_client_config.default.access_token
# }

# provider "kubectl" {
#   host                   = module.gke_autopilot_public.host
#   token                  = module.gke_autopilot_public.token
#   cluster_ca_certificate = module.gke_autopilot_public.cluster_ca_certificate
#   load_config_file       = false
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.gke_autopilot_public.host
#     token                  = module.gke_autopilot_public.token
#     cluster_ca_certificate = module.gke_autopilot_public.cluster_ca_certificate
#   }
# }

# # Start off with a general org level account
# provider "google" {
#   alias = "impersonate"

#   scopes = [
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/userinfo.email",
#   ]
# }
# # Use project level account to control blast radius
# data "google_service_account_access_token" "default" {
#   provider               = google.impersonate
#   target_service_account = "terraform@${var.project_id}.iam.gserviceaccount.com"
#   scopes = [
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/userinfo.email",
#   ]
# }

# provider "google" {
#   access_token = data.google_service_account_access_token.default.access_token
# }

# ### Google Groups section. Using org-terraform@prj-seed-09a8.iam.gserviceaccount.com so don't have to make each local
# #### Terraform account a directory admin
# data "google_service_account_access_token" "admin_directory" {
#   provider               = google.impersonate
#   target_service_account = "group-tf@prj-seed-09a8.iam.gserviceaccount.com"
#   scopes = [
#     "https://www.googleapis.com/auth/userinfo.email",
#     "https://www.googleapis.com/auth/admin.directory.group",
#   ]
# }

# provider "googleworkspace" {
#   customer_id  = "C00vq9h34" # example.net
#   access_token = data.google_service_account_access_token.admin_directory.access_token
# }

# provider "mongodbatlas" {}

# provider "datadog" {}
