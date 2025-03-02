terraform {
  backend "gcs" {
    bucket = "bkt-us-prj-b-seed-k8s-apps-tfstate-dd4a"
    prefix = "terraform/lab-infra/kubernetes-apps/development/us-central1"
  }
}
