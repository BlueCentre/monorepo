# https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev
# https://external-secrets.io/latest/provider/google-secrets-manager/
# https://console.cloud.google.com/iam-admin/serviceaccounts?project=prj-lab-james-nguyen&supportedpurview=project
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/workload-identity
# module "external_secrets_workload_identity" {
#   count               = var.external_secrets_enabled ? 1 : 0
#   source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
#   version             = "~> 33.0"
#   name                = "external-secrets"
#   namespace           = "external-secrets"
#   cluster_name        = data.terraform_remote_state.google_container_cluster.outputs.gke_cluster_name
#   location            = var.region
#   project_id          = var.project_id
#   use_existing_gcp_sa = true
#   use_existing_k8s_sa = true
#   # If annotation is disabled (via annotate_k8s_sa = false), the existing Kubernetes service account
#   # must already bear the "iam.gke.io/gcp-service-account" annotation.
#   annotate_k8s_sa = false
#   # https://cloud.google.com/secret-manager/docs/access-control
#   # https://cloud.google.com/iam/docs/roles-overview
#   # - Secret Manager Secret Accessor
#   # - Service Account Token Creator
#   roles = [
#     "roles/secretmanager.secretAccessor",
#     "roles/iam.serviceAccountTokenCreator",
#   ]
# }

# https://github.com/external-secrets/external-secrets/releases
# https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "external_secrets" {
  count            = var.external_secrets_enabled ? 1 : 0
  name             = "external-secrets"
  chart            = "external-secrets"
  version          = "0.14.4"
  repository       = "https://charts.external-secrets.io"
  description      = "Terraform driven Helm release of external-secrets Helm chart"
  namespace        = "external-secrets"
  create_namespace = true
  wait             = false

  # https://github.com/external-secrets/external-secrets/blob/main/deploy/charts/external-secrets/values.yaml

  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  values = [
    templatefile(
      "${path.module}/helm_values/external_secrets_values.yaml.tpl",
      {
        # gcpCommonProjectID     = "prj-example-com-secrets-665b", # data.org.outputs.org_secrets_project_id,
        # gcpProjectID           = var.project_id,
        # gcpServiceAccountEmail = module.external_secrets_workload_identity[count.index].gcp_service_account_email, # "external-secrets@${var.project_id}.iam.gserviceaccount.com"
        # k8sServiceAccountEmail = module.external_secrets_workload_identity[count.index].k8s_service_account_name,
      }
    )
  ]
}


# Fake provider for Cloudflare API Token in local development - RESTORED
resource "kubectl_manifest" "patch_fake_cloudflare_external_secret" {
  count      = var.external_secrets_enabled ? 1 : 0
  yaml_body  = <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: external-secret-cluster-fake-cloudflare-secrets
  namespace: external-secrets
spec:
  provider:
    fake:
      data:
      - key: "CLOUDFLARE_API_TOKEN"
        value: "${var.cloudflare_api_token}"
        version: "v1"
EOF
  depends_on = [helm_release.external_secrets]
}

# Fake provider for Datadog API key in local development - RESTORED
resource "kubectl_manifest" "patch_fake_datadog_external_secret" {
  count      = var.external_secrets_enabled && var.datadog_enabled ? 1 : 0
  yaml_body  = <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: external-secret-cluster-fake-datadog-secrets
  namespace: external-secrets
spec:
  provider:
    fake:
      data:
      - key: "DATADOG_API_KEY"
        value: "${var.datadog_api_key}"
        version: "v1"
      - key: "DATADOG_APP_KEY"
        value: "${var.datadog_api_key}"
        version: "v1"
      - key: "token"
        value: "${var.datadog_api_key}"
        version: "v1"
EOF
  depends_on = [helm_release.external_secrets]
}

# Fake provider for CNPG DB Credentials in local development - NEW
resource "kubectl_manifest" "fake_cnpg_secrets_store" {
  count      = var.external_secrets_enabled && var.cnpg_enabled ? 1 : 0
  yaml_body  = <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: external-secret-cluster-fake-cnpg-secrets
  namespace: external-secrets
spec:
  provider:
    fake:
      data:
      - key: "username"
        value: "${var.cnpg_app_db_user}"
        version: "v1"
      - key: "password"
        value: "${var.cnpg_app_db_password}"
        version: "v1"
EOF
  depends_on = [helm_release.external_secrets]
}


















# Design Notes:
# - This is a workaround to patch the external-secrets helm because extraObjects
#   in values yaml requires namepsace and CRDs to be created first so we add this
#   after chart is installed.

# https://console.cloud.google.com/kubernetes/objectKind/external-secrets.io/clustersecretstores?apiVersion=v1beta1&project=prj-lab-james-nguyen&supportedpurview=project
# resource "kubectl_manifest" "patch_com_external_secret" {
#   count      = var.external_secrets_enabled ? 1 : 0
#   yaml_body  = <<EOF
# apiVersion: external-secrets.io/v1beta1
# kind: ClusterSecretStore
# metadata:
#   name: external-secret-cluster-org-common-secrets
#   namespace: external-secrets
# spec:
#   provider:
#     gcpsm:
#       projectID: "prj-example-com-secrets-665b"
# EOF
#   depends_on = [helm_release.external_secrets]
# }

# https://console.cloud.google.com/kubernetes/objectKind/external-secrets.io/clustersecretstores?apiVersion=v1beta1&project=prj-lab-james-nguyen&supportedpurview=project
# resource "kubectl_manifest" "patch_prj_external_secret" {
#   count      = var.external_secrets_enabled ? 1 : 0
#   yaml_body  = <<EOF
# apiVersion: external-secrets.io/v1beta1
# kind: ClusterSecretStore
# metadata:
#   name: external-secret-cluster-lab-secrets
#   namespace: external-secrets
# spec:
#   provider:
#     gcpsm:
#       projectID: ${var.project_id}
# EOF
#   depends_on = [helm_release.external_secrets]
# }


# module "shared_cloudflare_token" {
#   count                = var.config_cluster ? 1 : 0
#   source               = "app.terraform.io/example/secret/google//modules/accessor"
#   version              = "1.0.0"
#   environment          = "com"
#   tenant               = "example"
#   secret_id            = "cloudflare_token"
#   member_account_email = module.external_secrets_workload_identity[0].gcp_service_account_email
# }

# resource "googleworkspace_group_member" "member" {
#   count    = var.config_cluster ? 1 : 0
#   group_id = "r_datadog_api_key_secret_accessor_org@example.net"
#   email    = module.external_secrets_workload_identity[0].gcp_service_account_email
#   role     = "MEMBER"
# }


# https://github.com/exampleInc/ooms-sharedcomponents/blob/main/kustomize/components/external-secrets/clustersecretstore.yaml
# https://external-secrets.io/latest/provider/google-secrets-manager/
