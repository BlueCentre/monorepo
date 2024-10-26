terraform {
  backend "gcs" {
    bucket = "bkt-us-prj-b-seed-gcp-region-tfstate-dd4a"
    prefix = "terraform/lab-infra/google-region/development/us-central1"
  }
}
