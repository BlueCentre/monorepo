/******************************************
 Groups permissions
*****************************************/

# resource "google_organization_iam_member" "security_reviewer" {
#   count  = var.gcp_groups.security_reviewer != null && local.parent_folder == "" ? 1 : 0
#   org_id = local.org_id
#   role   = "roles/iam.securityReviewer"
#   member = "group:${var.gcp_groups.security_reviewer}"
# }

# resource "google_folder_iam_member" "security_reviewer" {
#   count  = var.gcp_groups.security_reviewer != null && local.parent_folder != "" ? 1 : 0
#   folder = "folders/${local.parent_folder}"
#   role   = "roles/iam.securityReviewer"
#   member = "group:${var.gcp_groups.security_reviewer}"
# }

# resource "google_organization_iam_member" "network_viewer" {
#   count  = var.gcp_groups.network_viewer != null && local.parent_folder == "" ? 1 : 0
#   org_id = local.org_id
#   role   = "roles/compute.networkViewer"
#   member = "group:${var.gcp_groups.network_viewer}"
# }

# resource "google_folder_iam_member" "network_viewer" {
#   count  = var.gcp_groups.network_viewer != null && local.parent_folder != "" ? 1 : 0
#   folder = "folders/${local.parent_folder}"
#   role   = "roles/compute.networkViewer"
#   member = "group:${var.gcp_groups.network_viewer}"
# }

# resource "google_project_iam_member" "audit_log_viewer" {
#   count   = var.gcp_groups.audit_viewer != null ? 1 : 0
#   project = module.org_audit_logs.project_id
#   role    = "roles/logging.viewer"
#   member  = "group:${var.gcp_groups.audit_viewer}"
# }

# resource "google_project_iam_member" "audit_private_logviewer" {
#   count   = var.gcp_groups.audit_viewer != null ? 1 : 0
#   project = module.org_audit_logs.project_id
#   role    = "roles/logging.privateLogViewer"
#   member  = "group:${var.gcp_groups.audit_viewer}"
# }

# resource "google_project_iam_member" "audit_bq_data_viewer" {
#   count   = var.gcp_groups.audit_viewer != null ? 1 : 0
#   project = module.org_audit_logs.project_id
#   role    = "roles/bigquery.dataViewer"
#   member  = "group:${var.gcp_groups.audit_viewer}"
# }

# resource "google_organization_iam_member" "org_scc_admin" {
#   count  = var.gcp_groups.scc_admin != null && local.parent_folder == "" ? 1 : 0
#   org_id = local.org_id
#   role   = "roles/securitycenter.adminEditor"
#   member = "group:${var.gcp_groups.scc_admin}"
# }

# resource "google_project_iam_member" "project_scc_admin" {
#   count   = var.gcp_groups.scc_admin != null ? 1 : 0
#   project = module.scc_notifications.project_id
#   role    = "roles/securitycenter.adminEditor"
#   member  = "group:${var.gcp_groups.scc_admin}"
# }

# resource "google_project_iam_member" "global_secrets_admin" {
#   count   = var.gcp_groups.global_secrets_admin != null ? 1 : 0
#   project = module.org_secrets.project_id
#   role    = "roles/secretmanager.admin"
#   member  = "group:${var.gcp_groups.global_secrets_admin}"
# }

# resource "google_project_iam_member" "kms_admin" {
#   count   = var.gcp_groups.kms_admin != null ? 1 : 0
#   project = module.common_kms.project_id
#   role    = "roles/cloudkms.viewer"
#   member  = "group:${var.gcp_groups.kms_admin}"
# }

# resource "google_project_iam_member" "cai_monitoring_builder" {
#   project = module.scc_notifications.project_id
#   for_each = toset([
#     "roles/logging.logWriter",
#     "roles/storage.objectViewer",
#     "roles/artifactregistry.writer",
#   ])
#   role   = each.key
#   member = "serviceAccount:${google_service_account.cai_monitoring_builder.email}"
# }
