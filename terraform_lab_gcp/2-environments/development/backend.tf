terraform {
  backend "gcs" {
    bucket = "bkt-us-prj-b-seed-tfstate-dd4a"
    prefix = "terraform/environments/development"
  }
}
