# https://cloudnative-pg.io/documentation/
# https://cloudnative-pg.io/charts/
# https://github.com/cloudnative-pg/charts
# https://artifacthub.io/packages/helm/cloudnative-pg/cloudnative-pg
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "cnpg_operator" {
  count            = var.cnpg_enabled ? 1 : 0
  name             = "cnpg"
  chart            = "cloudnative-pg"
  version          = "0.23.2"
  repository       = "https://cloudnative-pg.github.io/charts"
  description      = "Terraform driven Helm release of CloudNativePG OperatorHelm chart"
  namespace        = "cnpg-system"
  create_namespace = true
  replace          = true
  wait             = true

  # https://github.com/cloudnative-pg/cloudnative-pg/blob/main/charts/cloudnative-pg/values.yaml
  values = [
    templatefile(
      # "${path.module}/helm_values/cnpg_cluster_values.yaml.tpl",
      "${path.module}/helm_values/cnpg_operator_values.yaml.tpl",
      {
        # Add any template variables here if needed
      }
    )
  ]
}

# Create a Kubernetes secret for the CNPG application user credentials
resource "kubernetes_secret" "cnpg_app_credentials" {
  count = var.cnpg_enabled ? 1 : 0
  metadata {
    name      = "cnpg-initial-app-credentials" # Secret name referenced by Cluster bootstrap
    namespace = helm_release.cnpg_cluster[0].namespace
  }
  data = {
    username = var.cnpg_app_db_user
    password = var.cnpg_app_db_password
  }
  type = "kubernetes.io/basic-auth"

  # depends_on = [
  #   # Ensure namespace exists before creating secret
  #   helm_release.cnpg_cluster
  # ]
}

resource "helm_release" "cnpg_cluster" {
  count            = var.cnpg_enabled ? 1 : 0
  name             = "cnpg"
  chart            = "cluster"
  version          = "0.2.1"
  repository       = "https://cloudnative-pg.github.io/charts"
  description      = "Terraform driven Helm release of CloudNativePG Cluster chart"
  namespace        = var.cnpg_cluster_namespace
  create_namespace = true
  wait             = false

  # https://github.com/cloudnative-pg/cloudnative-pg/blob/main/charts/cloudnative-pg/values.yaml
  values = [
    templatefile(
      "${path.module}/helm_values/cnpg_cluster_values.yaml.tpl",
      {
        # Add any template variables here if needed
        cnpg_app_db_name     = var.cnpg_app_db_name
        cnpg_app_db_user     = var.cnpg_app_db_user
        cnpg_app_db_password = var.cnpg_app_db_password
        cnpg_secret_name     = "cnpg-initial-app-credentials" #kubernetes_secret.cnpg_app_credentials[0].metadata[0].name
      }
    )
  ]

  # depends_on = [
  #   # Depend on the sleep resource, which depends on the Helm release
  #   time_sleep.wait_for_cnpg_webhook 
  # ]
  depends_on = [
    helm_release.cnpg_operator
  ]
}
