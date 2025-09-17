# TODO: Some reason this module complains on apply if service account does not already exist
# https://github.com/terraform-google-modules/terraform-google-iam/tree/master/modules/projects_iam
module "project_iam" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version  = "~> 7.7.1"
  projects = [var.project_id]
  mode     = "additive"
  bindings = {
    "roles/editor" = [
      "serviceAccount:${module.service_accounts.service_accounts_map["crossplane"].email}",
    ]
    # "roles/appengine.appAdmin" = [
    #   "serviceAccount:my-sa@my-project.iam.gserviceaccount.com",
    #   "group:my-group@my-org.com",
    #   "user:my-user@my-org.com",
    # ]
  }
}


# resource "google_project_iam_member" "artifact_registry_developer" {
#   project = var.project_id
#   role    = "roles/artifactregistry.writer"
#   member  = "group:gcp-do@example.com"
# }
