locals {
  # restricted_project_id        = data.terraform_remote_state.org.outputs.shared_vpc_projects[var.env].restricted_shared_vpc_project_id
  # restricted_project_number    = data.terraform_remote_state.org.outputs.shared_vpc_projects[var.env].restricted_shared_vpc_project_number
  base_project_id              = data.terraform_remote_state.org.outputs.shared_vpc_projects[var.env].base_shared_vpc_project_id
  # interconnect_project_number  = data.terraform_remote_state.org.outputs.interconnect_project_number
  # dns_hub_project_id           = data.terraform_remote_state.org.outputs.dns_hub_project_id
  # organization_service_account = data.terraform_remote_state.bootstrap.outputs.organization_step_terraform_service_account_email
  # networks_service_account     = data.terraform_remote_state.bootstrap.outputs.networks_step_terraform_service_account_email
  # projects_service_account     = data.terraform_remote_state.bootstrap.outputs.projects_step_terraform_service_account_email
}

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
