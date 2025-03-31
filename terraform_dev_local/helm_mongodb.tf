# https://github.com/mongodb/helm-charts/tree/main/charts/community-operator-crds
resource "helm_release" "mongodb_operator_crds" {
  count            = var.mongodb_enabled ? 1 : 0
  name             = "mongodb-operator-crds"
  repository       = "https://mongodb.github.io/helm-charts"
  chart            = "community-operator-crds"
  version          = var.mongodb_operator_version # Use variable for version
  description      = "Terraform driven Helm release of MongoDB Community Operator CRDs"
  namespace        = var.mongodb_namespace # Use variable for namespace
  create_namespace = true                  # Let Helm create the namespace
  wait             = true
  timeout          = 600
}

# https://github.com/mongodb/helm-charts/tree/main/charts/community-operator
# https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/docs/install-upgrade.md
# https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/docs/deploy-configure.md
resource "helm_release" "mongodb_operator" {
  count            = var.mongodb_enabled ? 1 : 0
  name             = "mongodb-operator"
  repository       = "https://mongodb.github.io/helm-charts"
  chart            = "community-operator"
  version          = var.mongodb_operator_version # Use variable for version
  description      = "Terraform driven Helm release of MongoDB Community Operator"
  namespace        = var.mongodb_namespace # Use variable for namespace
  create_namespace = true                  # Let Helm create the namespace
  wait             = true
  timeout          = 600

  # Load values from the template file
  values = [
    templatefile("${path.module}/helm_values/mongodb_community_operator_values.yaml.tpl", {
      # Pass variables needed by the template
      community_operator_crds_enabled = false # Enable the Helm chart to create the MongoDB resource
      create_resource                 = false # Create the MongoDB replicaset resource
      mongodb_replicaset_name         = var.mongodb_replicaset_name
      mongodb_replicaset_version      = var.mongodb_replicaset_version
      mongodb_replicaset_members      = var.mongodb_replicaset_members
    })
  ]

  # Ensure the secret is created before Helm tries to use it.
  # depends_on = [kubernetes_secret.mongodb_password[0]]
  depends_on = [helm_release.mongodb_operator_crds]
}

# Create a Kubernetes secret for MongoDB password
resource "kubernetes_secret" "mongodb_password" {
  count = var.mongodb_enabled ? 1 : 0
  metadata {
    name      = "mongodb-password"
    namespace = helm_release.mongodb_operator[0].namespace # Use variable for namespace
  }

  data = {
    password = var.mongodb_password
  }

  # No explicit depends_on needed here as helm_release depends on it
}

# The kubectl_manifest.mongodb_community resource block has been removed.
# Ensure any other resources that depended on it are updated if necessary.

# ... potentially other resources ...
