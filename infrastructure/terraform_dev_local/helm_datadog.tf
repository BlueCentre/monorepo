# Design notes:
# - This is only for reference as we use argocd to install the Datadog agent
# - Getting this to work requires the Datadog provider and a service account
#   that can access the common project datadog_api secret

# data "google_secret_manager_secret_version" "datadog_api_key" {
#   count    = var.datadog_enabled ? 1 : 0
#   provider = google.impersonate
#   secret   = "datadog_api_key"
#   project  = "prj-example-com-secrets-665b" #TODO hard code this, or keep simple?
# }

# https://app.datadoghq.com/infrastructure?netviz=sent_vol%3A%3A%2Ctcp_r_pct%3A%3A%2Crtt%3A%3A&tab=agent-configuration&tags=example_owner%3Aplatform&text=example_tenant%3Ademo
# https://www.datadoghq.com/blog/gke-autopilot-monitoring/#deploy-datadog-on-gke-autopilot
# https://github.com/DataDog/helm-charts/releases
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "datadog_agent" {
  count            = var.datadog_enabled ? 1 : 0
  name             = "datadog"
  chart            = "datadog"
  version          = "3.74.1"
  repository       = "https://helm.datadoghq.com"
  description      = "Terraform driven Helm release of Datadog Helm chart"
  namespace        = "datadog"
  create_namespace = true
  wait             = false
  max_history      = 1

  # https://github.com/DataDog/helm-charts/blob/main/charts/datadog/values.yaml

  values = [
    templatefile(
      "${path.module}/helm_values/datadog_values.yaml.tpl",
      {
        # domain           = "argocd-dev.lab.example.io",
        # hostname         = "argocd-dev.lab.example.io",
        # iapClientID      = data.google_secret_manager_secret_version_access.argocd_iap_client_id[count.index].secret_data,
        # iapClientSecret  = data.google_secret_manager_secret_version_access.argocd_iap_client_secret[count.index].secret_data,
        # argocdAdminEmail = data.google_client_openid_userinfo.me.email,
      }
    )
  ]

  # set_sensitive {
  #   name  = "datadog.apiKey"
  #   value = data.google_secret_manager_secret_version.datadog_api_key[count.index].secret_data
  # }
  # #  set { # Only run agent on a specific node pool to save money, match node label in google_container_node_pool.primary_zone_on_demand_datadog
  # #    name  = "agents.nodeSelector.example_datadog"
  # #    value = "monitored"
  # #  }
  # # set { # To avoid running on the same nodes running dpe-api
  # #   name  = "clusterAgent.nodeSelector.node_pool"
  # #   value = "default-node-pool"
  # # }
  # set {
  #   name  = "datadog.dogstatsd.useHostPort" # Sets the hostPort to the same value of the container port
  #   value = "true"
  # }
  # set {
  #   name  = "datadog.apm.portEnabled" # Enable APM over TCP communication (port 8126 by default)
  #   value = "true"
  # }
  # set { #  Enables this to activate Datadog Agent log collection
  #   name  = "datadog.logs.enabled"
  #   value = "true"
  # }
  # set {
  #   name  = "datadog.logs.autoMultiLineDetection"
  #   value = "true"
  # }
  # set { #  this is required with datadog.logs.enabled to actually log anything
  #   name  = "datadog.logs.containerCollectAll"
  #   value = "true"
  # }
  # set { # Next exclude all container logs
  #   name  = "datadog.containerExcludeLogs"
  #   value = "kube_namespace:kube-system kube_namespace:^.*"
  # }
  # # set { # finally only collect logs from [application] container
  # #   name  = "datadog.containerIncludeLogs"
  # #   value = "name:ooms"
  # # }
  # set {
  #   name  = "datadog.env[0].name"
  #   value = "DD_CLOUD_PROVIDER_METADATA"
  # }
  # set {
  #   name  = "datadog.env[0].value"
  #   value = "gcp"
  # }
  # set {
  #   name  = "datadog.tags"
  #   value = "env:${var.environment} example_tenant:${var.tenant}"
  # }

  # set {
  #   name  = "datadog.otlp.receiver.protocols.grpc.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "datadog.otlp.receiver.protocols.grpc.useHostPort"
  #   value = "false"
  # }

  # set {
  #   name  = "datadog.otlp.receiver.protocols.http.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "datadog.otlp.receiver.protocols.http.useHostPort"
  #   value = "false"
  # }
}


# https://console.cloud.google.com/kubernetes/objectKind/external-secrets.io/clustersecretstores?apiVersion=v1beta1&project=prj-lab-james-nguyen&supportedpurview=project
resource "kubectl_manifest" "patch_lab_external_secret_datadog" {
  count     = (var.external_secrets_enabled && var.datadog_enabled) ? 1 : 0
  yaml_body = <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: datadog-external-secrets
  namespace: datadog
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: external-secret-cluster-fake-datadog-secrets
    # name: external-secret-cluster-lab-secrets # NOTE: This is for the lab environment in GCP
  target:
    creationPolicy: Owner
    name: datadog
  data:
  - secretKey: token
    remoteRef:
      key: DATADOG_API_KEY
      version: v1
  - secretKey: api-key
    remoteRef:
      key: DATADOG_API_KEY
      version: v1
  - secretKey: app-key
    remoteRef:
      key: DATADOG_APP_KEY
      version: v1
EOF
  depends_on = [
    helm_release.external_secrets,
    helm_release.datadog_agent
  ]
}
