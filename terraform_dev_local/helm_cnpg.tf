# https://cloudnative-pg.io/documentation/
# https://cloudnative-pg.io/charts/
# https://github.com/cloudnative-pg/charts
# https://artifacthub.io/packages/helm/cloudnative-pg/cloudnative-pg
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "cloudnative_pg" {
  count            = var.cnpg_enabled ? 1 : 0
  name             = "cnpg"
  chart            = "cloudnative-pg" # NOTICE: Could be cluster chart
  version          = "0.23.2"
  repository       = "https://cloudnative-pg.github.io/charts"
  description      = "Terraform driven Helm release of CloudNativePG Helm chart"
  namespace        = "cnpg-system"
  create_namespace = true
  wait             = false

  # https://github.com/cloudnative-pg/cloudnative-pg/blob/main/charts/cloudnative-pg/values.yaml
  values = [
    templatefile(
      # "${path.module}/helm_values/cnpg_cluster_values.yaml.tpl",
      "${path.module}/helm_values/cnpg_values.yaml.tpl",
      {
        # Add any template variables here if needed
      }
    )
  ]
}
