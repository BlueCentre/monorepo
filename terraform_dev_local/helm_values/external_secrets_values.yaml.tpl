# https://github.com/external-secrets/external-secrets/blob/main/deploy/charts/external-secrets/values.yaml

installCRDs: true

leaderElect: true

crds:
  createClusterExternalSecret: true
  createClusterSecretStore: true

serviceAccount:
  create: true
  # annotations:
  #   # iam.gke.io/gcp-service-account: {gcpServiceAccountEmail}
  #   iam.gke.io/gcp-service-account: {k8sServiceAccountEmail}

webhook:
  create: false

certController:
  create: false

resources:
  limits:
    cpu: "250m"
    memory: "512Mi"
  requests:
    cpu: "50m"
    memory: "128Mi"

# https://cloudlogging.app.goo.gl/jebh9hPe44QPKTwk8
