# resource "google_storage_bucket" "my_pet" {
#   name     = "${var.project_id}-${random_pet.pet.id}-${random_string.suffix.id}"
#   location = "US"
# }

module "gcs_buckets" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 3.2.0"

  project_id       = var.project_id
  location         = var.project_location
  prefix           = var.bucket_prefix
  randomize_suffix = true
  set_admin_roles  = true

  names = [
    "prj-b-seed-tfstate",
    "prj-b-seed-gcp-project-tfstate",
    "prj-b-seed-gcp-region-tfstate",
    "prj-b-seed-gcp-zone-tfstate",
    "prj-b-seed-gcp-container-cluster-tfstate",
    "prj-b-seed-k8s-apps-tfstate"
  ]
  admins = ["group:gcp-do@example.com"]
  versioning = {
    first = true
  }
  bucket_admins = {
    second = "user:james.nguyen@example.com"
  }

  # force_destroy = {
  #   "prj-b-seed-bootstrap-tfstate" = var.bucket_force_destroy,
  #   "prj-b-seed-org-tfstate" = var.bucket_force_destroy,
  #   "prj-b-seed-environments-tfstate" = var.bucket_force_destroy,
  #   "prj-b-seed-networks-tfstate" = var.bucket_force_destroy,
  # }
}
