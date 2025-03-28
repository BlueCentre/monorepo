# https://github.com/mongodb/helm-charts/tree/main/charts/community-operator
# https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/docs/install-upgrade.md
# https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/docs/deploy-configure.md
resource "helm_release" "mongodb_operator" {
  count            = var.mongodb_enabled ? 1 : 0
  name             = "mongodb-operator"
  repository       = "https://mongodb.github.io/helm-charts"
  chart            = "community-operator"
  version          = "0.8.3"  # Using the stable version that works with our environment
  description      = "Terraform driven Helm release of MongoDB Community Operator"
  namespace        = "mongodb"
  create_namespace = true  # Let Helm create the namespace
  wait             = true
  timeout          = 600

  set {
    name  = "operator.watchNamespace"
    value = "mongodb"
  }

  # Don't create the MongoDB resource in the Helm chart - we'll create it separately
  set {
    name  = "createResource"
    value = "false"
  }
}

# Create a Kubernetes secret for MongoDB password
resource "kubernetes_secret" "mongodb_password" {
  count = var.mongodb_enabled ? 1 : 0
  metadata {
    name      = "mongodb-password"
    namespace = "mongodb"
  }

  data = {
    password = var.mongodb_password
  }

  depends_on = [helm_release.mongodb_operator] # Ensure namespace exists before creating secret
}

# Create the MongoDB resource after the operator is installed
resource "kubectl_manifest" "mongodb_community" {
  count = var.mongodb_enabled ? 1 : 0
  yaml_body = <<YAML
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: mongodb-rs
  namespace: mongodb
spec:
  members: 1
  type: ReplicaSet
  version: "4.4.19"
  featureCompatibilityVersion: "4.4"
  security:
    authentication:
      modes: ["SCRAM"]
  users:
    - name: root
      db: admin
      passwordSecretRef:
        name: mongodb-password
      roles:
        - name: readWriteAnyDatabase
          db: admin
      scramCredentialsSecretName: mongodb-scram
  statefulSet:
    spec:
      serviceName: mongodb-svc
      selector:
        matchLabels:
          app: mongodb-svc
      template:
        metadata:
          labels:
            app: mongodb-svc
      volumeClaimTemplates:
        - metadata:
            name: data-volume
          spec:
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: 8Gi
YAML

  depends_on = [
    helm_release.mongodb_operator,
    kubernetes_secret.mongodb_password
  ]
}
