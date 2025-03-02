module "env" {
  source = "../../modules/environments_baseline"

  env                 = "nonproduction"
  environment_code    = "n"
  remote_state_bucket = var.remote_state_bucket
  # tfc_org_name        = var.tfc_org_name
}
