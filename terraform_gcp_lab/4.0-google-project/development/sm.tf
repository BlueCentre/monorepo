module "secret_manager" {
  source     = "../../modules/secret_manager"
  project_id = var.project_id
  secrets = {
    upper("cloudflare_api_token")                  = null
    upper("iap_client_id")                         = null
    upper("iap_client_secret")                     = null
    upper("argocd_iap_client_id")                  = null
    upper("argocd_iap_client_secret")              = null
    upper("terraform_lab_project_repo_url")        = null
    upper("terraform_lab_project_ssh_private_key") = null
    upper("datadog_api_key")                       = null
    upper("datadog_app_key")                       = null
    upper("backstage_username")                    = null
    upper("backstage_password")                    = null
    upper("backstage_backend")                     = null
    upper("backstage_postgres")                    = null
  }
  # Secrets not listed below will be populated manually
  versions = {
    # upper("cloudflare_api_token") = {
    #   v1 = { enabled = true, data = "Manually created in cloud console" }
    # },
    upper("iap_client_id") = {
      v1 = { enabled = true, data = try(google_iap_client.project_client.client_id, "") }
    },
    upper("iap_client_secret") = {
      v1 = { enabled = true, data = try(google_iap_client.project_client.secret, "") }
    }
  }
}


# resource "google_secret_manager_secret" "cloudflare_secret" {
#   secret_id = upper("cloudflare_api_token")
#   project   = var.project_id
#   replication {
#     auto {}
#   }
# }
