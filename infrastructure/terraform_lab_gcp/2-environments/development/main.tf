module "env" {
  source = "../../modules/environments_baseline"

  env                 = "development"
  environment_code    = "d"
  remote_state_bucket = var.remote_state_bucket
#   tfc_org_name        = var.tfc_org_name
}
