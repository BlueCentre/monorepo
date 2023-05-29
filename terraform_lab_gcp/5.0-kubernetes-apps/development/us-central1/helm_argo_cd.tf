# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version_access
data "google_secret_manager_secret_version_access" "argocd_iap_client_id" {
  count   = var.argocd_enabled ? 1 : 0
  project = var.project_id
  secret  = upper("argocd_iap_client_id")
  # version = "latest" # Uncomment for specific version
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version_access
data "google_secret_manager_secret_version_access" "argocd_iap_client_secret" {
  count   = var.argocd_enabled ? 1 : 0
  project = var.project_id
  secret  = upper("argocd_iap_client_secret")
  # version = "latest" # Uncomment for specific version
}

# - # https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#gke

# https://console.cloud.google.com/iam-admin/serviceaccounts/details/106201307026273643395/permissions?project=prj-lab-james-nguyen&supportedpurview=project
# https://console.cloud.google.com/iam-admin/serviceaccounts/details/106351052023564388357/permissions?project=prj-lab-james-nguyen&supportedpurview=project
# https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev
# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/workload-identity
module "argocd_workload_identity" {
  for_each = var.argocd_enabled ? toset([
    "argocd-application-controller",
    "argocd-server",
  ]) : []
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "~> 33.0"
  name                = each.value
  namespace           = "argocd"
  cluster_name        = data.terraform_remote_state.google_container_cluster.outputs.gke_cluster_name
  location            = var.region
  project_id          = var.project_id
  use_existing_gcp_sa = true
  use_existing_k8s_sa = true
  # If annotation is disabled (via annotate_k8s_sa = false), the existing Kubernetes service account
  # must already bear the "iam.gke.io/gcp-service-account" annotation.
  annotate_k8s_sa = true
  # https://cloud.google.com/secret-manager/docs/access-control
  # https://cloud.google.com/iam/docs/roles-overview
  roles = [
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountTokenCreator",
    "roles/container.clusterViewer",
    # "roles/iam.serviceAccounts.getAccessToken", # Not supported for this resource
  ]
  # depends_on = [helm_release.argocd]
}


# https://console.cloud.google.com/kubernetes/secret/us-central1/lab-jn-dev-usc1-1/argocd/argocd-iap-oauth-client?project=prj-lab-james-nguyen&supportedpurview=project
# https://console.cloud.google.com/kubernetes/secret/us-central1/lab-jn-dev-usc1-1/argocd/argocd-secret?project=prj-lab-james-nguyen&supportedpurview=project
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "argocd" {
  count            = var.argocd_enabled ? 1 : 0
  name             = "argocd"
  chart            = "argo-cd"
  version          = "7.4.5"
  repository       = "https://argoproj.github.io/argo-helm"
  description      = "Terraform driven Helm release of ArgoCD Helm chart"
  namespace        = "argocd"
  create_namespace = true
  wait             = false

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml

  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  values = [
    templatefile(
      "${path.module}/helm_values/argocd_values.yaml.tpl",
      {
        # https://console.cloud.google.com/apis/credentials/oauthclient/681831149067-9qif0l6nn4etv66fv73dgndquinnasvk.apps.googleusercontent.com?project=prj-lab-james-nguyen&supportedpurview=project
        domain           = "argocd-dev.lab.example.io",
        hostname         = "argocd-dev.lab.example.io",
        iapClientID      = data.google_secret_manager_secret_version_access.argocd_iap_client_id[count.index].secret_data,
        iapClientSecret  = data.google_secret_manager_secret_version_access.argocd_iap_client_secret[count.index].secret_data,
        argocdAdminEmail = data.google_client_openid_userinfo.me.email,
      }
    )
  ]
  # depends_on = [kubectl_manifest.patch_external_dns_secret]
}

# resource "helm_release" "argocd_image_updater" {
#   count      = var.argocd_enabled ? 1 : 0
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd-image-updater"
#   version    = "7.3.11"
#   name       = "argocd-image-updater"
# }

resource "kubectl_manifest" "patch_argocd_bootstrap" {
  count      = var.external_dns_enabled && var.argocd_enabled ? 1 : 0
  yaml_body  = <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd-bootstrap
  namespace: argocd
  labels:
    # This label is required to access secret values when OAuth configurations
    app.kubernetes.io/part-of: argocd 
spec:
  project: default
  source:
    repoURL: 'git@github.com:ipv1337/terraform-lab-project.git'
    path: 6.0-gitops-argocd
    targetRevision: HEAD
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: argocd
  syncPolicy: {}
  EOF
  depends_on = [helm_release.argocd]
}


# https://cloud.google.com/blog/products/containers-kubernetes/connect-gateway-with-argocd
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#gke-application-load-balancer
# https://medium.com/@tharukam/configuring-argo-cd-on-gke-with-ingress-iap-and-google-oauth-for-rbac-a746fd009b78
# https://blog.saintmalik.me/argocd-on-kubernetes-cluster/
# https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/
# https://piotrminkowski.com/2024/06/28/backstage-on-kubernetes/

# BUGS:
# - depends_on does not work so apply twice is needed
