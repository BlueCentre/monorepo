# https://cert-manager.io/docs/installation/
# https://cert-manager.io/docs/installation/helm/
# https://github.com/cert-manager/cert-manager/releases
# https://artifacthub.io/packages/helm/cert-manager/cert-manager
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "cert_manager" {
  count            = var.cert_manager_enabled ? 1 : 0
  name             = "cert-manager"
  chart            = "cert-manager"
  version          = "v1.17.0"
  repository       = "https://charts.jetstack.io"
  description      = "Terraform driven Helm release of cert-manager Helm chart"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = false

  # TODO: https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters#add_firewall_rules

  # https://cert-manager.io/docs/installation/best-practice/#best-practice-helm-chart-values
  # https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml

  # https://developer.hashicorp.com/terraform/language/functions/templatefile
  values = [
    templatefile(
      "${path.module}/helm_values/cert_manager_values.yaml.tpl",
      {
        leaderElectionNamespace = "cert-manager",
      }
    )
  ]
}

# resource "kubectl_manifest" "clusterissuer_letsencrypt" {
#   count              = var.cert_manager_enabled ? 1 : 0
#   yaml_body          = file("${path.module}/cert_manager_clusterissuer_letsencrypt_${var.environment}.yaml")
#   override_namespace = "cert-manager"
#   # depends_on = [
#   #   helm_release.ingress_nginx,
#   #   helm_release.cert_manager,
#   # ]
# }


# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#gke-application-load-balancer
# https://medium.com/@tharukam/configuring-argo-cd-on-gke-with-ingress-iap-and-google-oauth-for-rbac-a746fd009b78
# https://blog.saintmalik.me/argocd-on-kubernetes-cluster/
# https://piotrminkowski.com/2022/06/28/manage-kubernetes-cluster-with-terraform-and-argo-cd/
# https://piotrminkowski.com/2024/06/28/backstage-on-kubernetes/
