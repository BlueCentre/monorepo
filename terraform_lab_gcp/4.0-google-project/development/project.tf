module "project_services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "~> 15.0"
  project_id                  = var.project_id
  disable_services_on_destroy = false
  activate_api_identities = [{
    api = "container.googleapis.com",
    roles = [
      "roles/cloudkms.cryptoKeyDecrypter",
      "roles/cloudkms.cryptoKeyEncrypter"
    ],
  }]
  activate_apis = [
    "container.googleapis.com",
    "secretmanager.googleapis.com",
    "certificatemanager.googleapis.com",
    "dataflow.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "spanner.googleapis.com",
    "trafficdirector.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "multiclusteringress.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "iam.googleapis.com",
    "ids.googleapis.com",
    "sqladmin.googleapis.com",
    "autoscaling.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "networkservices.googleapis.com",
    "iap.googleapis.com"
  ]
}
