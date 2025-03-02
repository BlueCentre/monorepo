# resource "google_storage_bucket" "my_pet" {
#   name     = "${var.project_id}-${random_pet.pet.id}-${random_string.suffix.id}"
#   location = "US"
# }

# module "gcs_buckets" {
#   source  = "terraform-google-modules/cloud-storage/google"
#   version = "~> 3.2.0"

#   project_id       = var.project_id
#   location         = var.project_location
#   names            = ["first", "second"]
#   prefix           = "bckt"
#   randomize_suffix = true
#   set_admin_roles  = true

#   admins = ["group:gcp-do@flyrlabs.com"]
#   versioning = {
#     first = true
#   }
#   bucket_admins = {
#     second = "user:james.nguyen@flyrlabs.com"
#   }
# }
