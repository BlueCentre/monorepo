locals {
  # default_region1 = "us-central1" # data.terraform_remote_state.bootstrap.outputs.common_config.default_region_1
  # default_region2 = "us-west1" # data.terraform_remote_state.bootstrap.outputs.common_config.default_region_2
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
