# DESIGN and LIMITATIONS:
# - IAP Brand is limited to 1 per project and lacks the ability to manage brand attributes
# - IAP Client lacks the ability to manage additional application specific attributes
# - What we can manage in Terraform is limited to internal applications


# NOTE: Only 1 allowed per GCP Project
# gcloud iap oauth-brands list --project=prj-lab-james-nguyen
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_brand
resource "google_iap_brand" "project_brand" {
  project           = data.google_project.project.project_id
  application_title = "Cloud IAP Protected Lab Application"
  support_email     = "james.nguyen@example.com"
}

# NOTE: Currently useless as this is unuseable by applications because we cannot manage:
# - Authorized JavaScript origins
# - Authorized redirect URIs
# https://console.cloud.google.com/apis/credentials?project=prj-lab-james-nguyen&supportedpurview=project
# https://cloud.google.com/iap/docs/custom-oauth-configuration#when_to_use_a_custom_oauth_configuration
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client
resource "google_iap_client" "project_client" {
  brand        = google_iap_brand.project_brand.name
  display_name = "IAP Client for ${upper(var.tenant)} ${title(var.environment)}"
}


# NOTE: Only needed if there is an existing brand as we cannot delete a brand from a project
# import {
#   id = "projects/${var.project_id}/brands/681831149067"
#   to = google_iap_brand.project_brand
# }
