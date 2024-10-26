module "bootstrap_secret_manager" {
  source     = "../modules/secret_manager"
  project_id = var.project_id
  secrets = {
    upper("github_pat_token") = null
  }
  # versions = {
  #   upper("harness_platform_terraform_account_id") = {
  #     v1 = { enabled = true, data = harness_platform_service_account.terraform.id }
  #   },
  #   upper("harness_platform_terraform_api_key") = {
  #     v1 = { enabled = true, data = harness_platform_token.terraform.value }
  #   }
  # }
  # depends_on = [module.project_services]
}
