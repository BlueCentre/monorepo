# https://console.cloud.google.com/iam-admin/serviceaccounts?project=prj-lab-james-nguyen&supportedpurview=project
# https://github.com/terraform-google-modules/terraform-google-service-accounts
module "service_accounts" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.2"
  project_id = var.project_id
  # prefix        = "test-sa"
  names = [
    "external-secrets",
    "external-dns",
    "argocd-server",
    "argocd-application-controller",
    "crossplane",
  ]
  # SA above will be bound to workload identity pool instead of project roles
  # project_roles = [
  #   "project-foo=>roles/viewer",
  #   "project-spam=>roles/storage.objectViewer",
  # ]
}


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account.html
# resource "google_service_account" "app_service_accounts" {
#   # for_each = {
#   #   for app, meta in local.apps :
#   #   app => meta
#   #   if try(meta.iam_name, null) != null
#   # }
#   account_id                   = "external-secrets" # replace(each.value.iam_name, "_", "-")
#   display_name                 = "External Secrets Service Account" # "${title(replace(each.value.iam_name, "-", " "))} Service Account"
#   description                  = "Managed by Terraform"
#   create_ignore_already_exists = true
#   # Add other properties for the service account
# }
