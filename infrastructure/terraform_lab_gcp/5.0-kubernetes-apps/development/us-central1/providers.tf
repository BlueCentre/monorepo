provider "google" {
  project = var.project_id # "prj-lab-james-nguyen"
  region  = var.region # "us-central1"
  zone    = var.project_zone # "us-central1-f"
}

provider "kubernetes" {
  host                   = module.gke_auth.host
  token                  = module.gke_auth.token
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = module.gke_auth.host
    token                  = module.gke_auth.token
    cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  }
}

provider "kustomization" {
  # one of kubeconfig_path, kubeconfig_raw or kubeconfig_incluster must be set

  # kubeconfig_path = "${path.module}/.kubeconfig"
  # kubeconfig_path = "~/.kube/config"
  # can also be set using KUBECONFIG_PATH environment variable

  kubeconfig_raw = module.gke_auth.kubeconfig_raw
  # kubeconfig_raw = data.template_file.kubeconfig.rendered
  # kubeconfig_raw = yamlencode(local.kubeconfig)

  # kubeconfig_incluster = true
}

provider "kubectl" {
  host                   = module.gke_auth.host
  token                  = module.gke_auth.token
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  load_config_file       = false
}


# # Start off with a general org level account
# provider "google" {
#   alias = "impersonate"

#   scopes = [
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/userinfo.email",
#   ]
# }
# # Use project level account to control blast radius
# data "google_service_account_access_token" "default" {
#   provider               = google.impersonate
#   target_service_account = "terraform@${var.project_id}.iam.gserviceaccount.com"
#   scopes = [
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/userinfo.email",
#   ]
# }

# provider "google" {
#   access_token = data.google_service_account_access_token.default.access_token
# }

# ### Google Groups section. Using org-terraform@prj-seed-09a8.iam.gserviceaccount.com so don't have to make each local
# #### Terraform account a directory admin
# data "google_service_account_access_token" "admin_directory" {
#   provider               = google.impersonate
#   target_service_account = "group-tf@prj-seed-09a8.iam.gserviceaccount.com"
#   scopes = [
#     "https://www.googleapis.com/auth/userinfo.email",
#     "https://www.googleapis.com/auth/admin.directory.group",
#   ]
# }

# provider "googleworkspace" {
#   customer_id  = "C00vq9h34" # example.net
#   access_token = data.google_service_account_access_token.admin_directory.access_token
# }

# provider "mongodbatlas" {}

# provider "datadog" {}
