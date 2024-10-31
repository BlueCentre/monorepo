locals {
  network_name = data.terraform_remote_state.google_region.outputs.network_name
  # subnat_name  = data.terraform_remote_state.google_region.outputs.base_subnets_names # TODO: parse list of strings and match region
  # subnet_names = [for subnet_self_link in module.vpc.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
  # TODO: get base_subnets_secondary_ranges
  # TODO: get base_subnets_self_links
  # REF: terraform state show data.terraform_remote_state.network
}

# https://console.cloud.google.com/storage/browser?project=prj-lab-james-nguyen&supportedpurview=project&prefix=&forceOnBucketsSortingFiltering=true

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}

data "terraform_remote_state" "org" {
  backend = "gcs"
  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/org/state"
  }
}

data "terraform_remote_state" "environments" {
  backend = "gcs"
  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/${var.environment}"
  }
}

data "terraform_remote_state" "networks" {
  backend = "gcs"
  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/${var.environment}"
  }
}



data "terraform_remote_state" "google_project" {
  backend = "gcs"
  config = {
    bucket = "bkt-us-prj-b-seed-gcp-project-tfstate-dd4a"
    prefix = "terraform/lab-infra/google-project/${var.environment}"
  }
}

data "terraform_remote_state" "google_region" {
  backend = "gcs"
  config = {
    bucket = "bkt-us-prj-b-seed-gcp-region-tfstate-dd4a"
    prefix = "terraform/lab-infra/google-region/${var.environment}/${var.region}"
  }
}
