# https://github.com/external-secrets/external-secrets/blob/main/deploy/charts/external-secrets/values.yaml

installCRDs: true

leaderElect: true

crds:
  createClusterExternalSecret: true
  createClusterSecretStore: true

serviceAccount:
  create: true
  annotations:
    iam.gke.io/gcp-service-account: ${gcpServiceAccountEmail}
    # iam.gke.io/gcp-service-account: ${k8sServiceAccountEmail}

# extraObjects:
#   # NOTE: These can only be added after the helm chart and CRDs are installed. (See TF design notes)
#   # https://console.cloud.google.com/kubernetes/objectKind/external-secrets.io/clustersecretstores?apiVersion=v1beta1&project=prj-lab-james-nguyen&supportedpurview=project
#   - apiVersion: external-secrets.io/v1beta1
#     kind: ClusterSecretStore
#     metadata:
#       name: external-secret-cluster-org-common-secrets
#       namespace: external-secrets
#     spec:
#       provider:
#         gcpsm:
#           projectID: ${gcpCommonProjectID}
#   - apiVersion: external-secrets.io/v1beta1
#     kind: ClusterSecretStore
#     metadata:
#       name: external-secret-cluster-lab-secrets
#       namespace: external-secrets
#     spec:
#       provider:
#         gcpsm:
#           projectID: ${gcpProjectID}
#   # Example usage:
#   # - apiVersion: external-secrets.io/v1beta1
#   #   kind: ExternalSecret
#   #   metadata:
#   #     name: argocd-external-secret
#   #     namespace: argocd
#   #     labels:
#   #       #This label is required to access secret values when OAuth configurations
#   #       app.kubernetes.io/part-of: argocd 
#   #   spec:
#   #     refreshInterval: 1h
#   #     secretStoreRef:
#   #       kind: ClusterSecretStore
#   #       name: external-secret-cluster-lab-secrets
#   #     target:
#   #       name: argocd-iap-oauth-client-secret
#   #       creationPolicy: Owner
#   #       template:
#   #         metadata:
#   #           labels:
#   #             service: argocd-server
#   #           annotations:
#   #             reloader.stakater.com/match: "true"
#   #     data:
#   #       - secretKey: client_id
#   #         remoteRef:
#   #           key: ARGOCD_IAP_CLIENT_ID
#   #       - secretKey: client_secret
#   #         remoteRef:
#   #           key: ARGOCD_IAP_CLIENT_SECRET

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
