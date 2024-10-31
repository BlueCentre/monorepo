provider "google" {
  project = var.project_id # "prj-lab-james-nguyen"
  region  = var.region # "us-central1"
  zone    = var.project_zone # "us-central1-f"
}

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
#   customer_id  = "C00vq9h34" # flyrlabs.net
#   access_token = data.google_service_account_access_token.admin_directory.access_token
# }

# provider "mongodbatlas" {}

# provider "datadog" {}
