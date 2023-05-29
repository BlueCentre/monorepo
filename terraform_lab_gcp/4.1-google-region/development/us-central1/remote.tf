locals {
  default_region1 = data.terraform_remote_state.bootstrap.outputs.common_config.default_region_1
  default_region2 = data.terraform_remote_state.bootstrap.outputs.common_config.default_region_2

  google_project_bucket = data.terraform_remote_state.bootstrap.outputs.google_project_bucket

  # shared based network
  # network_id                = data.terraform_remote_state.networks.outputs.NNNN_network_id
  # network_name              = data.terraform_remote_state.networks.outputs.base_network_name
  # project_network_self_link = data.terraform_remote_state.networks.outputs.base_network_self_link

  # project based network
  network_id                = data.terraform_remote_state.google_project.outputs.project_network_id
  network_name              = data.terraform_remote_state.google_project.outputs.project_network_name
  project_network_self_link = data.terraform_remote_state.google_project.outputs.project_network_self_link
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
    bucket = local.google_project_bucket
    prefix = "terraform/lab-infra/google-project/${var.environment}"
  }
}
