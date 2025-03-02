/******************************************
  Projects for Shared VPCs
*****************************************/

# module "base_shared_vpc_host_project" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 15.0"

#   random_project_id           = true
#   random_project_id_length    = 4
#   name                        = format("%s-%s-shared-base", var.project_prefix, var.env_code)
#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   folder_id                   = var.folder_id
#   disable_services_on_destroy = false

#   activate_apis = [
#     "compute.googleapis.com",
#     "dns.googleapis.com",
#     "servicenetworking.googleapis.com",
#     "container.googleapis.com",
#     "logging.googleapis.com",
#     "billingbudgets.googleapis.com"
#   ]

#   labels = {
#     environment       = var.env
#     application_name  = "base-shared-vpc-host"
#     billing_code      = "1234"
#     primary_contact   = "example1"
#     secondary_contact = "example2"
#     business_code     = "shared"
#     env_code          = var.env_code
#     vpc               = "base"
#   }
#   budget_alert_pubsub_topic   = var.project_budget.base_network_alert_pubsub_topic
#   budget_alert_spent_percents = var.project_budget.base_network_alert_spent_percents
#   budget_amount               = var.project_budget.base_network_budget_amount
# }

# module "restricted_shared_vpc_host_project" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 15.0"

#   random_project_id           = true
#   random_project_id_length    = 4
#   name                        = format("%s-%s-shared-restricted", var.project_prefix, var.env_code)
#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   folder_id                   = var.folder_id
#   disable_services_on_destroy = false

#   activate_apis = [
#     "compute.googleapis.com",
#     "dns.googleapis.com",
#     "servicenetworking.googleapis.com",
#     "container.googleapis.com",
#     "logging.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "accesscontextmanager.googleapis.com",
#     "billingbudgets.googleapis.com"
#   ]

#   labels = {
#     environment       = var.env
#     application_name  = "restricted-shared-vpc-host"
#     billing_code      = "1234"
#     primary_contact   = "example1"
#     secondary_contact = "example2"
#     business_code     = "shared"
#     env_code          = var.env_code
#     vpc               = "restricted"
#   }
#   budget_alert_pubsub_topic   = var.project_budget.restricted_network_alert_pubsub_topic
#   budget_alert_spent_percents = var.project_budget.restricted_network_alert_spent_percents
#   budget_amount               = var.project_budget.restricted_network_budget_amount
#   budget_alert_spend_basis    = var.project_budget.restricted_network_budget_alert_spend_basis
# }
