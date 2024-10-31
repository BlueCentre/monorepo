terraform {
  backend "gcs" {
    bucket = "bkt-us-prj-b-seed-gcp-container-cluster-tfstate-dd4a"
    prefix = "terraform/lab-infra/google-container-cluster/development/us-central1"
  }
}
