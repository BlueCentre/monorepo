terraform {
  backend "gcs" {
    bucket = "bkt-us-prj-b-seed-gcp-project-tfstate-dd4a"
    prefix = "terraform/lab-infra/google-project/nonproduction"
  }
}
