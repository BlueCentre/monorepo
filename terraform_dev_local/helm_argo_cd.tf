# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version_access
# data "google_secret_manager_secret_version_access" "argocd_iap_client_id" {
#   count   = var.argocd_enabled ? 1 : 0
#   project = var.project_id
#   secret  = upper("argocd_iap_client_id")
#   # version = "latest" # Uncomment for specific version
# }

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version_access
# data "google_secret_manager_secret_version_access" "argocd_iap_client_secret" {
#   count   = var.argocd_enabled ? 1 : 0
#   project = var.project_id
#   secret  = upper("argocd_iap_client_secret")
#   # version = "latest" # Uncomment for specific version
# }

# - # https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#gke

# https://console.cloud.google.com/iam-admin/serviceaccounts/details/106201307026273643395/permissions?project=prj-lab-james-nguyen&supportedpurview=project
# https://console.cloud.google.com/iam-admin/serviceaccounts/details/106351052023564388357/permissions?project=prj-lab-james-nguyen&supportedpurview=project
# https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev
# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/workload-identity
# module "argocd_workload_identity" {
#   for_each = var.argocd_enabled ? toset([
#     "argocd-application-controller",
#     "argocd-server",
#   ]) : []
#   source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
#   version             = "~> 33.0"
#   name                = each.value
#   namespace           = "argocd"
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
#   # depends_on = [helm_release.argocd]
# }


# https://console.cloud.google.com/kubernetes/secret/us-central1/lab-jn-dev-usc1-1/argocd/argocd-iap-oauth-client?project=prj-lab-james-nguyen&supportedpurview=project
# https://console.cloud.google.com/kubernetes/secret/us-central1/lab-jn-dev-usc1-1/argocd/argocd-secret?project=prj-lab-james-nguyen&supportedpurview=project
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "argocd" {
  count            = var.argocd_enabled ? 1 : 0
  name             = "argocd"
  chart            = "argo-cd"
  version          = "7.8.2"
  repository       = "https://argoproj.github.io/argo-helm"
  description      = "Terraform driven Helm release of ArgoCD Helm chart"
  namespace        = "argocd"
  create_namespace = true
  wait             = false

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml

  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  values = [
    templatefile(
      # "${path.module}/helm_values/argocd_values.yaml.tpl",
      "${path.module}/helm_values/argocd_local.yaml.tpl",
      {
        # https://console.cloud.google.com/apis/credentials/oauthclient/681831149067-9qif0l6nn4etv66fv73dgndquinnasvk.apps.googleusercontent.com?project=prj-lab-james-nguyen&supportedpurview=project
        domain   = "localhost",
        hostname = "localhost",
        # domain           = "argocd-dev.lab.example.io",
        # hostname         = "argocd-dev.lab.example.io",
        # iapClientID      = data.google_secret_manager_secret_version_access.argocd_iap_client_id[count.index].secret_data,
        # iapClientSecret  = data.google_secret_manager_secret_version_access.argocd_iap_client_secret[count.index].secret_data,
        # argocdAdminEmail = data.google_client_openid_userinfo.me.email,
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
  # count      = var.external_dns_enabled && var.argocd_enabled ? 1 : 0
  count      = var.argocd_enabled ? 1 : 0
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
    repoURL: 'ssh://git@ssh.github.com:443/ipv1337/terraform-lab-project.git'
    path: 6.0-gitops-argocd
    targetRevision: HEAD
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: argocd
  syncPolicy: {}
  EOF
  depends_on = [helm_release.argocd]
}

# resource "kubectl_manifest" "patch_argocd_example" {
#   # count      = var.external_dns_enabled && var.argocd_enabled ? 1 : 0
#   count      = var.argocd_enabled ? 1 : 0
#   yaml_body  = <<EOF
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: guestbook
#   namespace: argocd
# spec:
#   project: default
#   source:
#     repoURL: https://github.com/argoproj/argocd-example-apps.git
#     targetRevision: HEAD
#     path: guestbook
#   destination:
#     server: https://kubernetes.default.svc
#     namespace: guestbook
#   syncPolicy:
#     automated:
#       prune: true
#       selfHeal: true
#     syncOptions:
#     - CreateNamespace=true
#   EOF
#   depends_on = [helm_release.argocd]
# }

# resource "kubectl_manifest" "patch_argocd_secret_template" {
#   # count      = var.external_dns_enabled && var.argocd_enabled ? 1 : 0
#   count      = var.argocd_enabled ? 1 : 0
#   yaml_body  = <<EOF
# apiVersion: v1
# kind: Secret
# metadata:
#   name: repo-lab-private
#   namespace: argocd
#   labels:
#     argocd.argoproj.io/secret-type: repo-creds
# stringData:
#   project: default
#   name: repo-lab
#   type: git
#   url: ssh://git@ssh.github.com:443/ipv1337/terraform-lab-project.git
#   sshPrivateKey: |
#     -----BEGIN OPENSSH PRIVATE KEY-----
#     MIIEoQIBAAKCAQEAnqIgF4tdek4xprHf2pfaHbweMARDTeiPYYNEQmLJBf9fumIJ
#     PdpAs8FG8+ovSVyn7GxwkgJIvPplFqTM7wxVzu7zLr4vd99Res0ts/GHRThKR9YV
#     tIJ5q8zJUnOWFfWRRY98dEe1t1HCs7UxDkgRs4OfeV20fmZ+ur6yrudtvPGaW7TK
#     wNsjOl/LzTi/ZnIyUI2XtlXIfsvA6zUeGlc5ghS8qvd21XVgmnrEIaDGWCO/gGPN
#     cC7cT/GQjoHM5b9c6tG5taqCHLTXcmPcpY2b5RNoxs2YyuH+oaRJaewwgoPj/n9o
#     ev+vFbmysX476P7TYRUDQ76eCJG3zgHy+g9UkwIBIwKCAQAoypqJth9Z9tmRQ66X
#     S558rLdOLPtdLSwvBH9ERUmidN4Z+/O/cqLsZOZb+mPuSwab4V7GdZ2s7+4bw/ou
#     10lD1wtVKZctc/BhZ/XPL3qOJGrfRa3PVMAzfc1eWDyJTcZFFkSS7d5FFQYuNegK
#     /JbWY6yqLgnXXC83VZupUXP9YksGMDiMNWFYPDPcpuA5AwFFSSkPyhxUrdNVb26V
#     uiM/8GXUjTxo4x/JRqcsXCgJhQDSMHEO7+C+kZV5I1UJVcMq+vJlcTA5XDAs3VMc
#     cA1NsT5w9BKXb5JOCYOGno5WZ5dqnIbrT6rBhPgTBfPfhrpUZllnT34fPI4xICd9
#     Ig7LAoGBAMpJn8LsgUXfUKjYFF58XwD53yjpa/rY0PVjNztJ7wQPsfTS2uomtKln
#     qVpJDfQeuZwZGbrW2RfcNj71lnk15HCKHrRor6+3dg3XLg2jt/uQamtCvdMZpg6t
#     iouIqb5dvBA0XfbKjFhyVgsTbkYVhUpzUjp1lYh73q6S7Wb5A9rhAoGBAMjBIJ2z
#     GH88z66bDTHTeUjXdXnIZgojyJWthW2mlFcH9MoPTKHBhlgHojUPnjaGLAPEG+km
#     W5NVvgxQDJc2OBHV/4+Jl/ppu9Veg8SvsBdC97VbBUSAwu/hETArErpi/BUrh9bI
#     BKIkl3EbMbM1USYXUTQ8ZblMHOBDJbmMMbHzAoGANARNpybfab0UvbPn+woJzQ0N
#     f4x62hp+4AOR3AuyfWMfIbKQEFMYg1UrjD6r0Q83CuHiC3kTQKZXF4D6zrYWK5E7
#     GHKw1WmwpHkpGXM98DsUDPPnq0+8/HXEike2nqpjjyNonova8iwHfzDh14Hgcjrp
#     Qjt+OQnozc4CiDFnZCsCgYEAwwTAmTGixL67HqVABIRJ7v0wSmrmyAWBBm4MlmdO
#     Rep4xElgYp69BQ661HWSYNocIOpkQZL535UfBKWIkuQ2d7nw8dYem3yn1pZUHicC
#     1MS2HeNkM+rL/vfkz7TQXUo2tXq+eN+PePBYmcKlTwCX+R33HMz1Gmcx/m0dVSka
#     VRcCgYARV5BVy8vvqIpsHLHYzlbbpd4Ea5lYu4iR7V8ns/mW7yt1pRXXapqEip04
#     22vylLptkzlNBNvN3jjK9k6LNTKOtHDOZSprfK9G+V9G4VTGOY5ZxUsAFSOuIDXB
#     nMlAGgvb6zqIfBAwuE15cmRo841EUyVREZT/fHQ4KknIYCBAkw==
#     -----END OPENSSH PRIVATE KEY-----
#   EOF
#   depends_on = [helm_release.argocd]
# }

resource "kubectl_manifest" "patch_argocd_secret_template" {
  # count      = var.external_dns_enabled && var.argocd_enabled ? 1 : 0
  count      = var.argocd_enabled ? 1 : 0
  yaml_body  = <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: repo-lab-template
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
data:
  project: ZGVmYXVsdA==
  name: bGFi
  type: Z2l0
  url: >-
    c3NoOi8vZ2l0QHNzaC5naXRodWIuY29tOjQ0My9pcHYxMzM3L3RlcnJhZm9ybS1sYWItcHJvamVjdC5naXQ=
  sshPrivateKey: >-
    LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb1FJQkFBS0NBUUVBbnFJZ0Y0dGRlazR4cHJIZjJwZmFIYndlTUFSRFRlaVBZWU5FUW1MSkJmOWZ1bUlKClBkcEFzOEZHOCtvdlNWeW43R3h3a2dKSXZQcGxGcVRNN3d4Vnp1N3pMcjR2ZDk5UmVzMHRzL0dIUlRoS1I5WVYKdElKNXE4ekpVbk9XRmZXUlJZOThkRWUxdDFIQ3M3VXhEa2dSczRPZmVWMjBmbVordXI2eXJ1ZHR2UEdhVzdUSwp3TnNqT2wvTHpUaS9abkl5VUkyWHRsWElmc3ZBNnpVZUdsYzVnaFM4cXZkMjFYVmdtbnJFSWFER1dDTy9nR1BOCmNDN2NUL0dRam9ITTViOWM2dEc1dGFxQ0hMVFhjbVBjcFkyYjVSTm94czJZeXVIK29hUkphZXd3Z29Qai9uOW8KZXYrdkZibXlzWDQ3NlA3VFlSVURRNzZlQ0pHM3pnSHkrZzlVa3dJQkl3S0NBUUFveXBxSnRoOVo5dG1SUTY2WApTNTU4ckxkT0xQdGRMU3d2Qkg5RVJVbWlkTjRaKy9PL2NxTHNaT1piK21QdVN3YWI0VjdHZFoyczcrNGJ3L291CjEwbEQxd3RWS1pjdGMvQmhaL1hQTDNxT0pHcmZSYTNQVk1BemZjMWVXRHlKVGNaRkZrU1M3ZDVGRlFZdU5lZ0sKL0piV1k2eXFMZ25YWEM4M1ZadXBVWFA5WWtzR01EaU1OV0ZZUERQY3B1QTVBd0ZGU1NrUHloeFVyZE5WYjI2Vgp1aU0vOEdYVWpUeG80eC9KUnFjc1hDZ0poUURTTUhFTzcrQytrWlY1STFVSlZjTXErdkpsY1RBNVhEQXMzVk1jCmNBMU5zVDV3OUJLWGI1Sk9DWU9Hbm81V1o1ZHFuSWJyVDZyQmhQZ1RCZlBmaHJwVVpsbG5UMzRmUEk0eElDZDkKSWc3TEFvR0JBTXBKbjhMc2dVWGZVS2pZRkY1OFh3RDUzeWpwYS9yWTBQVmpOenRKN3dRUHNmVFMydW9tdEtsbgpxVnBKRGZRZXVad1pHYnJXMlJmY05qNzFsbmsxNUhDS0hyUm9yNiszZGczWExnMmp0L3VRYW10Q3ZkTVpwZzZ0CmlvdUlxYjVkdkJBMFhmYktqRmh5VmdzVGJrWVZoVXB6VWpwMWxZaDczcTZTN1diNUE5cmhBb0dCQU1qQklKMnoKR0g4OHo2NmJEVEhUZVVqWGRYbklaZ29qeUpXdGhXMm1sRmNIOU1vUFRLSEJobGdIb2pVUG5qYUdMQVBFRytrbQpXNU5Wdmd4UURKYzJPQkhWLzQrSmwvcHB1OVZlZzhTdnNCZEM5N1ZiQlVTQXd1L2hFVEFyRXJwaS9CVXJoOWJJCkJLSWtsM0ViTWJNMVVTWVhVVFE4WmJsTUhPQkRKYm1NTWJIekFvR0FOQVJOcHliZmFiMFV2YlBuK3dvSnpRME4KZjR4NjJocCs0QU9SM0F1eWZXTWZJYktRRUZNWWcxVXJqRDZyMFE4M0N1SGlDM2tUUUtaWEY0RDZ6cllXSzVFNwpHSEt3MVdtd3BIa3BHWE05OERzVURQUG5xMCs4L0hYRWlrZTJucXBqanlOb25vdmE4aXdIZnpEaDE0SGdjanJwClFqdCtPUW5vemM0Q2lERm5aQ3NDZ1lFQXd3VEFtVEdpeEw2N0hxVkFCSVJKN3Ywd1Ntcm15QVdCQm00TWxtZE8KUmVwNHhFbGdZcDY5QlE2NjFIV1NZTm9jSU9wa1FaTDUzNVVmQktXSWt1UTJkN253OGRZZW0zeW4xcFpVSGljQwoxTVMySGVOa00rckwvdmZrejdUUVhVbzJ0WHErZU4rUGVQQlltY0tsVHdDWCtSMzNITXoxR21jeC9tMGRWU2thClZSY0NnWUFSVjVCVnk4dnZxSXBzSExIWXpsYmJwZDRFYTVsWXU0aVI3Vjhucy9tVzd5dDFwUlhYYXBxRWlwMDQKMjJ2eWxMcHRremxOQk52TjNqaks5azZMTlRLT3RIRE9aU3ByZks5RytWOUc0VlRHT1k1WnhVc0FGU091SURYQgpuTWxBR2d2YjZ6cUlmQkF3dUUxNWNtUm84NDFFVXlWUkVaVC9mSFE0S2tuSVlDQkFrdz09Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
  type: Z2l0
type: Opaque
  EOF
  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "patch_argocd_secret_repository" {
  # count      = var.external_dns_enabled && var.argocd_enabled ? 1 : 0
  count      = var.argocd_enabled ? 1 : 0
  yaml_body  = <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: repo-lab
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
  annotations:
    managed-by: argocd.argoproj.io
data:
  project: ZGVmYXVsdA==
  name: cHJpdmF0ZS1sYWI=
  type: Z2l0
  url: >-
    c3NoOi8vZ2l0QHNzaC5naXRodWIuY29tOjQ0My9pcHYxMzM3L3RlcnJhZm9ybS1sYWItcHJvamVjdC5naXQ=
  sshPrivateKey: >-
    LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb1FJQkFBS0NBUUVBbnFJZ0Y0dGRlazR4cHJIZjJwZmFIYndlTUFSRFRlaVBZWU5FUW1MSkJmOWZ1bUlKClBkcEFzOEZHOCtvdlNWeW43R3h3a2dKSXZQcGxGcVRNN3d4Vnp1N3pMcjR2ZDk5UmVzMHRzL0dIUlRoS1I5WVYKdElKNXE4ekpVbk9XRmZXUlJZOThkRWUxdDFIQ3M3VXhEa2dSczRPZmVWMjBmbVordXI2eXJ1ZHR2UEdhVzdUSwp3TnNqT2wvTHpUaS9abkl5VUkyWHRsWElmc3ZBNnpVZUdsYzVnaFM4cXZkMjFYVmdtbnJFSWFER1dDTy9nR1BOCmNDN2NUL0dRam9ITTViOWM2dEc1dGFxQ0hMVFhjbVBjcFkyYjVSTm94czJZeXVIK29hUkphZXd3Z29Qai9uOW8KZXYrdkZibXlzWDQ3NlA3VFlSVURRNzZlQ0pHM3pnSHkrZzlVa3dJQkl3S0NBUUFveXBxSnRoOVo5dG1SUTY2WApTNTU4ckxkT0xQdGRMU3d2Qkg5RVJVbWlkTjRaKy9PL2NxTHNaT1piK21QdVN3YWI0VjdHZFoyczcrNGJ3L291CjEwbEQxd3RWS1pjdGMvQmhaL1hQTDNxT0pHcmZSYTNQVk1BemZjMWVXRHlKVGNaRkZrU1M3ZDVGRlFZdU5lZ0sKL0piV1k2eXFMZ25YWEM4M1ZadXBVWFA5WWtzR01EaU1OV0ZZUERQY3B1QTVBd0ZGU1NrUHloeFVyZE5WYjI2Vgp1aU0vOEdYVWpUeG80eC9KUnFjc1hDZ0poUURTTUhFTzcrQytrWlY1STFVSlZjTXErdkpsY1RBNVhEQXMzVk1jCmNBMU5zVDV3OUJLWGI1Sk9DWU9Hbm81V1o1ZHFuSWJyVDZyQmhQZ1RCZlBmaHJwVVpsbG5UMzRmUEk0eElDZDkKSWc3TEFvR0JBTXBKbjhMc2dVWGZVS2pZRkY1OFh3RDUzeWpwYS9yWTBQVmpOenRKN3dRUHNmVFMydW9tdEtsbgpxVnBKRGZRZXVad1pHYnJXMlJmY05qNzFsbmsxNUhDS0hyUm9yNiszZGczWExnMmp0L3VRYW10Q3ZkTVpwZzZ0CmlvdUlxYjVkdkJBMFhmYktqRmh5VmdzVGJrWVZoVXB6VWpwMWxZaDczcTZTN1diNUE5cmhBb0dCQU1qQklKMnoKR0g4OHo2NmJEVEhUZVVqWGRYbklaZ29qeUpXdGhXMm1sRmNIOU1vUFRLSEJobGdIb2pVUG5qYUdMQVBFRytrbQpXNU5Wdmd4UURKYzJPQkhWLzQrSmwvcHB1OVZlZzhTdnNCZEM5N1ZiQlVTQXd1L2hFVEFyRXJwaS9CVXJoOWJJCkJLSWtsM0ViTWJNMVVTWVhVVFE4WmJsTUhPQkRKYm1NTWJIekFvR0FOQVJOcHliZmFiMFV2YlBuK3dvSnpRME4KZjR4NjJocCs0QU9SM0F1eWZXTWZJYktRRUZNWWcxVXJqRDZyMFE4M0N1SGlDM2tUUUtaWEY0RDZ6cllXSzVFNwpHSEt3MVdtd3BIa3BHWE05OERzVURQUG5xMCs4L0hYRWlrZTJucXBqanlOb25vdmE4aXdIZnpEaDE0SGdjanJwClFqdCtPUW5vemM0Q2lERm5aQ3NDZ1lFQXd3VEFtVEdpeEw2N0hxVkFCSVJKN3Ywd1Ntcm15QVdCQm00TWxtZE8KUmVwNHhFbGdZcDY5QlE2NjFIV1NZTm9jSU9wa1FaTDUzNVVmQktXSWt1UTJkN253OGRZZW0zeW4xcFpVSGljQwoxTVMySGVOa00rckwvdmZrejdUUVhVbzJ0WHErZU4rUGVQQlltY0tsVHdDWCtSMzNITXoxR21jeC9tMGRWU2thClZSY0NnWUFSVjVCVnk4dnZxSXBzSExIWXpsYmJwZDRFYTVsWXU0aVI3Vjhucy9tVzd5dDFwUlhYYXBxRWlwMDQKMjJ2eWxMcHRremxOQk52TjNqaks5azZMTlRLT3RIRE9aU3ByZks5RytWOUc0VlRHT1k1WnhVc0FGU091SURYQgpuTWxBR2d2YjZ6cUlmQkF3dUUxNWNtUm84NDFFVXlWUkVaVC9mSFE0S2tuSVlDQkFrdz09Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
  enableLfs: dHJ1ZQ==
type: Opaque
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
