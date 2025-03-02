# # us-central1-docker.pkg.dev/prj-lab-james-nguyen/lab-images
# # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository
# resource "google_artifact_registry_repository" "lab_repo" {
#   project       = var.project_id
#   location      = var.project_region
#   repository_id = var.artifact_registry_name
#   description   = "Lab docker repository"
#   format        = "DOCKER"
#   depends_on    = [
#     google_project_service.enable_service_artifact_registry
#   ]
# }

# # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam
# # resource "google_artifact_registry_repository_iam_member" "member" {
# #   project    = google_artifact_registry_repository.lab_repo.project
# #   location   = google_artifact_registry_repository.lab_repo.location
# #   repository = google_artifact_registry_repository.lab_repo.name
# #   role       = "roles/artifactregistry.reader"
# #   member     = "serviceAccount:681831149067-compute@developer.gserviceaccount.com"
# # }
