# https://github.com/bitnami/charts/tree/main/bitnami/redis
# https://artifacthub.io/packages/helm/bitnami/redis
# https://github.com/bitnami/charts/blob/main/bitnami/redis/values.yaml
resource "helm_release" "redis" {
  count            = var.redis_enabled ? 1 : 0
  name             = "redis"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "redis"
  version          = "18.19.1"
  description      = "Terraform driven Helm release of Bitnami Redis chart for both Istio rate limiting and application usage"
  namespace        = "redis"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    templatefile(
      "${path.module}/helm_values/redis_values.yaml.tpl",
      {
        namespace = "redis"
      }
    )
  ]

  set {
    name  = "auth.password"
    value = var.redis_password
  }

  set {
    name  = "master.podSecurityContext.fsGroup"
    value = "1001"
  }

  set {
    name  = "master.containerSecurityContext.runAsUser"
    value = "1001"
  }
}
