# https://artifacthub.io/packages/helm/external-dns/external-dns
# https://bitnami.com/stack/external-dns/helm
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "external_dns" {
  count      = var.external_dns_enabled ? 1 : 0
  name       = "external-dns"
  chart      = "external-dns"
  version    = "1.15.0"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  # version          = "8.3.9"
  # repository       = "https://charts.bitnami.com/bitnami"
  description      = "Terraform driven Helm release of external-dns Helm chart"
  namespace        = "external-dns"
  create_namespace = true
  wait             = false

  # https://github.com/kubernetes-sigs/external-dns/blob/master/charts/external-dns/values.yaml
  # https://github.com/bitnami/charts/blob/main/bitnami/external-dns/values.yaml

  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  values = [
    templatefile(
      "${path.module}/helm_values/external_dns_values.yaml.tpl",
      {
        cfSecretName     = "cf-secret",
        cfSecretKey      = "cloudflare-api-key",
        txtOwnerId       = "bluecentre-dev",
        annotationFilter = "external-dns.alpha.kubernetes.io/sync-enabled in (true)",
      }
    )
  ]
}


# https://registry.terraform.io/providers/alekc/kubectl/latest/docs
# https://console.cloud.google.com/kubernetes/objectKind/external-secrets.io/externalsecrets?apiVersion=v1beta1&project=prj-lab-james-nguyen&supportedpurview=project
# https://console.cloud.google.com/kubernetes/secret/us-central1/lab-jn-dev-usc1-1/external-dns/cf-secret?project=prj-lab-james-nguyen&supportedpurview=project

# sigs
resource "kubectl_manifest" "patch_external_dns_secret" {
  count     = var.external_dns_enabled ? 1 : 0
  yaml_body = <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: cf-external-secret
  namespace: external-dns
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: external-secret-cluster-fake-cloudflare-secrets
  target:
    name: cf-secret
    creationPolicy: Owner
    template:
      metadata:
        labels:
          service: external-dns
        annotations:
          reloader.stakater.com/match: "true"
  data:
    - secretKey: cloudflare-api-key
      remoteRef:
        key: CLOUDFLARE_API_TOKEN
        version: v1
  EOF
  depends_on = [
    helm_release.external_secrets,
    helm_release.external_dns
  ]
}

# bitnami
# resource "kubectl_manifest" "patch_external_dns_secret" {
#   count      = var.external_dns_enabled ? 1 : 0
#   yaml_body  = <<EOF
# apiVersion: external-secrets.io/v1beta1
# kind: ExternalSecret
# metadata:
#   name: cf-external-secret
#   namespace: external-dns
# spec:
#   refreshInterval: 1h
#   secretStoreRef:
#     kind: ClusterSecretStore
#     name: external-secret-cluster-lab-secrets
#   target:
#     name: cf-secret
#     creationPolicy: Owner
#     template:
#       metadata:
#         labels:
#           service: external-dns
#         annotations:
#           reloader.stakater.com/match: "true"
#   data:
#     - secretKey: cloudflare_api_token
#       remoteRef:
#         key: CLOUDFLARE_API_TOKEN
#   EOF
#   depends_on = [helm_release.external_secrets, helm_release.external_dns]
# }


# https://github.com/exampleInc/ooms-sharedcomponents/blob/main/kustomize/components/external-dns/secret.yaml
# https://github.com/exampleInc/ooms-sharedcomponents/blob/main/kustomize/tenants/rx/testing/httproute-api-patch.yaml
