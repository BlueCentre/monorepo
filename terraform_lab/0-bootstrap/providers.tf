provider "google" {
  project = var.project_id     # "prj-lab-james-nguyen"
  region  = var.project_region # "us-central1"
  zone    = var.project_zone   # "us-central1-f"
}

# Configure the Harness provider for First Gen resources (uncomment if using Harness)
# provider "harness" {
#   endpoint   = "https://app.harness.io/gateway"
#   account_id = data.google_secret_manager_secret_version_access.harness_account_id[0].secret_data
#   api_key    = data.google_secret_manager_secret_version_access.harness_platform_api_key[0].secret_data
#   # account_id = harness_platform_service_account.terraform.id # data.google_secret_manager_secret_version_access.harness_account_id[0].secret_data
#   # api_key    = harness_platform_token.terraform.value # data.google_secret_manager_secret_version_access.harness_platform_api_key[0].secret_data
# }

# Configure the Harness provider for Next Gen resources (uncomment if using Harness)
# provider "harness" {
#   alias            = "nextgen"
#   endpoint         = "https://app.harness.io/gateway"
#   account_id       = data.google_secret_manager_secret_version_access.harness_account_id[0].secret_data
#   platform_api_key = data.google_secret_manager_secret_version_access.harness_platform_api_key[0].secret_data
#   # account_id       = harness_platform_service_account.terraform.id # data.google_secret_manager_secret_version_access.harness_account_id[0].secret_data
#   # platform_api_key = harness_platform_token.terraform.value # data.google_secret_manager_secret_version_access.harness_platform_api_key[0].secret_data
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
#   customer_id  = "C00vq9h34" # flyrlabs.net
#   access_token = data.google_service_account_access_token.admin_directory.access_token
# }

# provider "mongodbatlas" {}

# provider "datadog" {}
