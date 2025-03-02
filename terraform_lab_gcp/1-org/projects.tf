locals {
  # hub_and_spoke_roles = [
  #   "roles/compute.instanceAdmin",
  #   "roles/iam.serviceAccountAdmin",
  #   "roles/resourcemanager.projectIamAdmin",
  #   "roles/iam.serviceAccountUser",
  # ]
  environments = {
    "development" : "d",
    "nonproduction" : "n",
    "production" : "p"
  }
}

/************************************************************
  Base and Restricted Network Projects for each Environment
************************************************************/

module "base_restricted_environment_network" {
  source   = "../modules/network_project_mock"
  for_each = local.environments

  # org_id          = local.org_id
  # billing_account = local.billing_account
  # project_prefix  = local.project_prefix
  # folder_id       = google_folder.network.id

  env      = each.key
  env_code = each.value

  # project_budget = {
  #   base_network_budget_amount                  = var.project_budget.base_network_budget_amount
  #   base_network_alert_spent_percents           = var.project_budget.base_network_alert_spent_percents
  #   base_network_alert_pubsub_topic             = var.project_budget.base_network_alert_pubsub_topic
  #   base_network_budget_alert_spend_basis       = var.project_budget.base_network_budget_alert_spend_basis
  #   restricted_network_budget_amount            = var.project_budget.restricted_network_budget_amount
  #   restricted_network_alert_spent_percents     = var.project_budget.restricted_network_alert_spent_percents
  #   restricted_network_alert_pubsub_topic       = var.project_budget.restricted_network_alert_pubsub_topic
  #   restricted_network_budget_alert_spend_basis = var.project_budget.restricted_network_budget_alert_spend_basis
  # }
}

/*********************************************************************
  Roles granted to the networks SA for Hub and Spoke network topology
*********************************************************************/

# resource "google_project_iam_member" "network_sa_restricted" {
#   for_each = toset(var.enable_hub_and_spoke ? local.hub_and_spoke_roles : [])

#   project = module.restricted_network_hub[0].project_id
#   role    = each.key
#   member  = "serviceAccount:${local.networks_step_terraform_service_account_email}"
# }
