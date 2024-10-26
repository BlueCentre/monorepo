locals {
  default_region1 = data.terraform_remote_state.bootstrap.outputs.common_config.default_region_1
  default_region2 = data.terraform_remote_state.bootstrap.outputs.common_config.default_region_2
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}
