module "env" {
  source = "../../modules/environments_baseline"

  env                 = "production"
  environment_code    = "p"
  remote_state_bucket = var.remote_state_bucket
  # tfc_org_name        = var.tfc_org_name
}
