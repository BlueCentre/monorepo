# Uncomment if you need to use secrets from Secret Manager
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version_access
# data "google_secret_manager_secret_version_access" "example_iap_client_id" {
#   count   = var.istio_enabled ? 1 : 0
#   project = var.project_id
#   secret  = upper("example_iap_client_id")
#   # version = "latest" # Uncomment for specific version
# }

# Uncomment if you need to use secrets from Secret Manager
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version_access
# data "google_secret_manager_secret_version_access" "example_iap_client_secret" {
#   count   = var.istio_enabled ? 1 : 0
#   project = var.project_id
#   secret  = upper("example_iap_client_secret")
#   # version = "latest" # Uncomment for specific version
# }

# Uncomment if you want to use Workload Identity
# https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev
# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/workload-identity
# module "example_workload_identity" {
#   for_each = var.istio_enabled ? toset([
#     "example-service-account-1",
#     "example-service-account-2",
#   ]) : []
#   source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
#   version             = "31.1.0"
#   name                = each.value
#   namespace           = "example"
#   cluster_name        = data.terraform_remote_state.google_container_cluster.outputs.gke_cluster_name
#   location            = var.region
#   project_id          = var.project_id
#   use_existing_gcp_sa = true
#   use_existing_k8s_sa = true
#   # If annotation is disabled (via annotate_k8s_sa = false), the existing Kubernetes service account
#   # must already bear the "iam.gke.io/gcp-service-account" annotation.
#   annotate_k8s_sa = true
#   # https://cloud.google.com/secret-manager/docs/access-control
#   # https://cloud.google.com/iam/docs/roles-overview
#   roles = [
#     "roles/secretmanager.secretAccessor",
#     "roles/iam.serviceAccountTokenCreator",
#     "roles/container.clusterViewer",
#     # "roles/iam.serviceAccounts.getAccessToken", # Not supported for this resource
#   ]
#   # depends_on = [helm_release.example]
# }


# https://github.com/istio/istio/tree/master/manifests/charts/base
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "istio_base" {
  count            = var.istio_enabled ? 1 : 0
  name             = "istio-base"
  chart            = "base"
  version          = "1.23.3"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  description      = "Terraform driven Helm release of Istio Base Helm chart"
  namespace        = "istio-system"
  create_namespace = true
  wait             = false

  # https://github.com/istio/istio/blob/master/manifests/charts/base/values.yaml

  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  values = [
    templatefile(
      "${path.module}/helm_values/istio_base_values.yaml.tpl",
      {
        defaultRevision = "default",
      }
    )
  ]

  # depends_on = [kubectl_manifest.patch_external_dns_secret]
}

# https://chimbu.medium.com/installing-istio-not-anthos-service-mesh-on-gke-autopilot-2b78f1bbe90a
# https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-security
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/issues/1785
# https://github.com/istio/istio/tree/master/manifests/charts/istio-cni
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "istio_cni" {
  count            = var.istio_enabled ? 1 : 0
  name             = "istio-cni"
  chart            = "cni"
  version          = "1.23.3"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  description      = "Terraform driven Helm release of Istio CNI Helm chart"
  namespace        = "istio-system"
  create_namespace = false
  wait             = true
  wait_for_jobs    = true

  # https://github.com/istio/istio/blob/master/manifests/charts/istio-cni/values.yaml

  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  values = [
    templatefile(
      "${path.module}/helm_values/istio_cni_values.yaml.tpl",
      {
        cniBinDir = "/home/kubernetes/bin",
      }
    )
  ]

  depends_on = [helm_release.istio_base]
}

# Install Istio Control Plane (istiod)
resource "helm_release" "istiod" {
  count            = var.istio_enabled ? 1 : 0
  name             = "istiod"
  chart            = "istiod"
  version          = "1.23.3"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  description      = "Terraform driven Helm release of Istio Control Plane"
  namespace        = "istio-system"
  create_namespace = false
  wait             = true
  wait_for_jobs    = true

  values = [
    # file("${path.module}/helm_values/istiod-values.yaml")
  ]

  depends_on = [helm_release.istio_base, helm_release.istio_cni]
}

# Install Istio Ingress Gateway
resource "helm_release" "istio_ingressgateway" {
  count            = var.istio_enabled ? 1 : 0
  name             = "istio-ingressgateway"
  chart            = "gateway"
  version          = "1.23.3"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  description      = "Terraform driven Helm release of Istio Ingress Gateway"
  namespace        = "istio-system"
  create_namespace = false
  wait             = true
  wait_for_jobs    = true

  values = [
    # file("${path.module}/helm_values/istio-ingressgateway-values.yaml")
  ]

  depends_on = [helm_release.istio_base, helm_release.istiod]
}

# resource "helm_release" "argocd_image_updater" {
#   count      = var.argocd_enabled ? 1 : 0
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd-image-updater"
#   version    = "7.3.11"
#   name       = "argocd-image-updater"
# }

# Uncomment if you need to patch CRDs after Helm release
# resource "kubectl_manifest" "patch_example_bootstrap" {
#   count      = var.istio_enabled ? 1 : 0
#   yaml_body  = <<EOF
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: argocd-bootstrap
#   namespace: argocd
#   labels:
#     # This label is required to access secret values when OAuth configurations
#     app.kubernetes.io/part-of: argocd 
# spec:
#   project: default
#   source:
#     repoURL: 'git@github.com:ipv1337/terraform-lab-project.git'
#     path: 6.0-gitops-argocd
#     targetRevision: HEAD
#   destination:
#     server: 'https://kubernetes.default.svc'
#     namespace: argocd
#   syncPolicy: {}
#   EOF
#   depends_on = [helm_release.example]
# }


# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#gke-application-load-balancer
# https://medium.com/@tharukam/configuring-argo-cd-on-gke-with-ingress-iap-and-google-oauth-for-rbac-a746fd009b78
# https://blog.saintmalik.me/argocd-on-kubernetes-cluster/
# https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/
# https://piotrminkowski.com/2024/06/28/backstage-on-kubernetes/

# BUGS:
# - depends_on does not work so apply twice is needed
