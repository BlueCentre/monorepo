data "google_project" "project" {
  project_id = var.project_id
  depends_on = [module.project_services]
}

data "google_client_config" "default" {
  depends_on = [module.project_services]
}

data "google_compute_default_service_account" "default" {}
