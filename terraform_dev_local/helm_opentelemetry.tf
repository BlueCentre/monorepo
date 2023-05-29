# https://opentelemetry.io/docs/kubernetes/helm/operator/
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "opentelemetry_operator" {
  count            = var.opentelemetry_enabled ? 1 : 0
  name             = "opentelemetry-operator"
  chart            = "opentelemetry-operator"
  version          = "0.79.0"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  description      = "Terraform driven Helm release of the OpenTelemetry Operator Helm chart"
  namespace        = "opentelemetry"
  create_namespace = true
  wait             = false

  # https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/values.yaml

  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  values = [
    templatefile(
      "${path.module}/helm_values/opentelemetry_operator_values.yaml.tpl",
      {
        # domain = "argocd-dev.lab.example.io",
      }
    )
  ]
  depends_on = [helm_release.cert_manager]
}

# https://opentelemetry.io/docs/kubernetes/helm/collector/
# https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-operator#install-opentelemetry-collector
resource "helm_release" "opentelemetry_collector" {
  count            = var.opentelemetry_enabled ? 1 : 0
  name             = "opentelemetry-collector"
  chart            = "opentelemetry-collector"
  version          = "0.79.0"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  description      = "Terraform driven Helm release of the OpenTelemetry Operator Helm chart"
  namespace        = "opentelemetry"
  create_namespace = true
  wait             = false

  # https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-collector/values.yaml

  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  values = [
    templatefile(
      "${path.module}/helm_values/opentelemetry_collector_values.yaml.tpl",
      {
        mode = "deployment",
      }
    )
  ]
  depends_on = [helm_release.opentelemetry_operator]
}
