# https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#gke-application-load-balancer
# https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#gke

crds:
  install: true
  keep: false

global:
  domain: ${domain}
  additionalLabels:
    app: argocd
    cluster-type: worker

configs:
  # https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#gke-application-load-balancer
  # https://console.cloud.google.com/kubernetes/configmap/us-central1/lab-jn-dev-usc1-1/argocd/argocd-cmd-params-cm/details?project=prj-lab-james-nguyen&supportedpurview=project
  params:
    server.insecure: true
    # -- Enables [Applications in any namespace]
    ## List of additional namespaces where applications may be created in and reconciled from.
    ## The namespace where Argo CD is installed to will always be allowed.
    ## Set comma-separated list. (e.g. app-team-one, app-team-two)
    # application.namespaces: ""
  # https://console.cloud.google.com/kubernetes/configmap/us-central1/lab-jn-dev-usc1-1/argocd/argocd-rbac-cm/details?project=prj-lab-james-nguyen&supportedpurview=project
  rbac:
    policy.default: role:readonly
    policy.csv: |
      p, role:org-admin, applications, *, */*, allow
      p, role:org-admin, clusters, get, *, allow
      p, role:org-admin, repositories, *, *, allow
      p, role:org-admin, logs, get, *, allow
      p, role:org-admin, exec, create, */*, allow
      # g, {argocdAdminEmail}, role:org-admin
      # g, your-github-org:your-team, role:org-admin
    scopes: '[groups, email]'
  # https://console.cloud.google.com/kubernetes/configmap/us-central1/lab-jn-dev-usc1-1/argocd/argocd-cm/details?project=prj-lab-james-nguyen&supportedpurview=project
  # cm:
  #   dex.config: |
  #     # https://dexidp.io/docs/connectors/oidc/
  #     connectors:
  #     - type: oidc
  #       id: google
  #       name: Google
  #       config:
  #         # Connector config values starting with a "$" will read from the environment.
  #         issuer: https://accounts.google.com
  #         # $argocd-iap-oauth-client-secret:client_id
  #         clientID: {iapClientID}
  #         # $argocd-iap-oauth-client-secret:client_secret
  #         clientSecret: {iapClientSecret}
  #         # Dex's issuer URL + "/callback"
  #         # redirectURI: http://127.0.0.1:5556/callback
  #         # scopes:
  #         # - email
  #         # - profile
  #         # # - groups
  # -- Repository credentials to be used as Templates for other repos
  ## Creates a secret for each key/value specified below to create repository credentials
  credentialTemplates: {}
    # github-enterprise-creds-1:
    #   url: https://github.com/argoproj
    #   githubAppID: 1
    #   githubAppInstallationID: 2
    #   githubAppEnterpriseBaseUrl: https://ghe.example.com/api/v3
    #   githubAppPrivateKey: |
    #     -----BEGIN OPENSSH PRIVATE KEY-----
    #     ...
    #     -----END OPENSSH PRIVATE KEY-----
  # -- Repositories list to be used by applications
  ## Creates a secret for each key/value specified below to create repositories
  ## Note: the last example in the list would use a repository credential template, configured under "configs.credentialTemplates".
  repositories: {}
    # istio-helm-repo:
    #   url: https://storage.googleapis.com/istio-prerelease/daily-build/master-latest-daily/charts
    #   name: istio.io
    #   type: helm
    # private-helm-repo:
    #   url: https://my-private-chart-repo.internal
    #   name: private-repo
    #   type: helm
    #   password: my-password
    #   username: my-username
    # private-repo:
    #   url: https://github.com/argoproj/private-repo
  # -- Annotations to be added to `configs.repositories` Secret
  repositoriesAnnotations: {}
  # Argo CD sensitive data
  # Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#sensitive-data-and-sso-client-secrets
  secret:
    # -- Create the argocd-secret
    createSecret: true
    # -- Labels to be added to argocd-secret
    labels: {}
    # -- Annotations to be added to argocd-secret
    annotations: {}
    # -- Shared secret for authenticating GitHub webhook events
    githubSecret: ""
    # -- Shared secret for authenticating GitLab webhook events
    gitlabSecret: ""

# extraObjects:
# # Namespace will not exist on the first run so this will only succeed on the second run
# # https://console.cloud.google.com/kubernetes/secret/us-central1/lab-jn-dev-usc1-1/argocd/argocd-iap-oauth-client?project=prj-lab-james-nguyen&supportedpurview=project
# - apiVersion: external-secrets.io/v1beta1
#   kind: ExternalSecret
#   metadata:
#     name: argocd-external-secret
#     namespace: argocd
#     labels:
#       # This label is required to access secret values when OAuth configurations
#       app.kubernetes.io/part-of: argocd 
#   spec:
#     refreshInterval: 1h
#     secretStoreRef:
#       kind: ClusterSecretStore
#       name: external-secret-cluster-lab-secrets
#     target:
#       name: argocd-iap-oauth-client-secret
#       creationPolicy: Owner
#       template:
#         metadata:
#           labels:
#             service: argocd-server
#           annotations:
#             reloader.stakater.com/match: "true"
#     data:
#     - secretKey: client_id
#       remoteRef:
#         key: ARGOCD_IAP_CLIENT_ID
#     - secretKey: client_secret
#       remoteRef:
#         key: ARGOCD_IAP_CLIENT_SECRET
# # Namespace will not exist on the first run so this will only succeed on the second run
# - apiVersion: external-secrets.io/v1beta1
#   kind: ExternalSecret
#   metadata:
#     name: argocd-repo-terraform-lab-project
#     namespace: argocd
#     labels:
#       # This label is required to access secret values when OAuth configurations
#       app.kubernetes.io/part-of: argocd 
#   spec:
#     refreshInterval: 1h
#     secretStoreRef:
#       kind: ClusterSecretStore
#       name: external-secret-cluster-lab-secrets
#     target:
#       name: argocd-repo-terraform-lab-project
#       creationPolicy: Owner
#       template:
#         metadata:
#           labels:
#             argocd.argoproj.io/secret-type: repository
#     data: 
#     - secretKey: sshPrivateKey
#       remoteRef:
#         key: TERRAFORM_LAB_PROJECT_SSH_PRIVATE_KEY
#     - secretKey: url
#       remoteRef:
#         key: TERRAFORM_LAB_PROJECT_REPO_URL
# # CRD does not exist yet so this will fail
# # - apiVersion: argoproj.io/v1alpha1
# #   kind: Application
# #   metadata:
# #     name: argocd-bootstrap
# #     namespace: argocd
# #     labels:
# #       # This label is required to access secret values when OAuth configurations
# #       app.kubernetes.io/part-of: argocd 
# #   spec:
# #     project: default
# #     source:
# #       repoURL: 'git@github.com:ipv1337/terraform-lab-project.git'
# #       path: 6.0-gitops-argocd
# #       targetRevision: HEAD
# #       directory:
# #         recurse: true
# #     destination:
# #       server: 'https://kubernetes.default.svc'
# #       namespace: argocd
# #     syncPolicy:
# #       automated: {}
# #       syncOptions:
# #       - CreateNamespace=true

server:
  service:
    # https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#gke-application-load-balancer
    # https://console.cloud.google.com/kubernetes/service/us-central1/lab-jn-dev-usc1-1/argocd/argocd-server/details?project=prj-lab-james-nguyen&supportedpurview=project
    # https://console.cloud.google.com/kubernetes/objectKind/networking.gke.io/servicenetworkendpointgroups?apiVersion=v1beta1&project=prj-lab-james-nguyen&supportedpurview=project
    annotations:
      # https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#container-native_load_balancing
      cloud.google.com/neg: '{"ingress": true}'
      cloud.google.com/backend-config: '{"ports": {"http":"argocd-server"}}'
    type: LoadBalancer
  # ingress:
  #   # https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#gke-application-load-balancer
  #   # https://console.cloud.google.com/kubernetes/objectKind/networking.k8s.io/ingresses?apiVersion=v1&kind=INGRESS&project=prj-lab-james-nguyen&supportedpurview=project
  #   enabled: true
  #   annotations:
  #     external-dns.alpha.kubernetes.io/hostname: ${hostname}
  #     external-dns.alpha.kubernetes.io/sync-enabled: true
  #   controller: gke
  #   gke:
  #     # https://console.cloud.google.com/kubernetes/objectKind/cloud.google.com/backendconfigs?apiVersion=v1&kind=BACKEND_CONFIG&project=prj-lab-james-nguyen&supportedpurview=project
  #     backendConfig:
  #       healthCheck:
  #         checkIntervalSec: 30
  #         timeoutSec: 5
  #         healthyThreshold: 1
  #         unhealthyThreshold: 2
  #         type: HTTP
  #         requestPath: /healthz
  #         port: 8080
  #       # https://cloud.google.com/iap/docs/custom-oauth-configuration
  #       # https://cloud.google.com/iap/docs/enabling-kubernetes-howto#kubernetes-configure
  #       # iap:
  #       #   enabled: true
  #       #   # https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-configuration#enable_with_google_managed_oauth_client
  #       #   oauthclientCredentials:
  #       #     secretName: argocd-iap-oauth-client-secret
  #     # https://console.cloud.google.com/kubernetes/objectKind/networking.gke.io/frontendconfigs?apiVersion=v1beta1&project=prj-lab-james-nguyen&supportedpurview=project
  #     frontendConfig:
  #       redirectToHttps:
  #         enabled: true
  #     # https://console.cloud.google.com/security/ccm/list/lbCertificates?project=prj-lab-james-nguyen&supportedpurview=project
  #     # https://console.cloud.google.com/kubernetes/objectKind/networking.gke.io/managedcertificates?apiVersion=v1&kind=MANAGED_CERTIFICATE&project=prj-lab-james-nguyen&supportedpurview=project
  #     managedCertificate:
  #       enabled: true

# https://cloudlogging.app.goo.gl/nT74RiVz1zJHUPUj6
