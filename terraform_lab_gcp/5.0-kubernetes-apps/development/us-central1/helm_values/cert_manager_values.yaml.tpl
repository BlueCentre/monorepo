# https://cert-manager.io/docs/installation/best-practice/#best-practice-helm-chart-values

global:
  priorityClassName: system-cluster-critical
  # Override if running on GKE Autopilot since kube-system is wardened
  # https://cert-manager.io/docs/installation/compatibility/#gke-autopilot
  leaderElection:
    namespace: "${leaderElectionNamespace}"

crds:
  enabled: true
  keep: true

replicaCount: 2
podDisruptionBudget:
  enabled: true
  minAvailable: 1
# automountServiceAccountToken: false
# serviceAccount:
#   automountServiceAccountToken: false
# volumes:
# - name: serviceaccount-token
#   projected:
#     defaultMode: 0444
#     sources:
#     - serviceAccountToken:
#         expirationSeconds: 3607
#         path: token
#     - configMap:
#         name: kube-root-ca.crt
#         items:
#         - key: ca.crt
#           path: ca.crt
#     - downwardAPI:
#         items:
#         - path: namespace
#           fieldRef:
#             apiVersion: v1
#             fieldPath: metadata.namespace
# volumeMounts:
# - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
#   name: serviceaccount-token
#   readOnly: true

# webhook:
#   replicaCount: 3
#   podDisruptionBudget:
#     enabled: true
#     minAvailable: 1
#   automountServiceAccountToken: false
#   serviceAccount:
#     automountServiceAccountToken: false
#   volumes:
#   - name: serviceaccount-token
#     projected:
#       defaultMode: 0444
#       sources:
#       - serviceAccountToken:
#           expirationSeconds: 3607
#           path: token
#       - configMap:
#           name: kube-root-ca.crt
#           items:
#           - key: ca.crt
#             path: ca.crt
#       - downwardAPI:
#           items:
#           - path: namespace
#             fieldRef:
#               apiVersion: v1
#               fieldPath: metadata.namespace
#   volumeMounts:
#   - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
#     name: serviceaccount-token
#     readOnly: true

# cainjector:
#   extraArgs:
#   - --namespace=cert-manager
#   - --enable-certificates-data-source=false
#   replicaCount: 2
#   podDisruptionBudget:
#     enabled: true
#     minAvailable: 1
#   automountServiceAccountToken: false
#   serviceAccount:
#     automountServiceAccountToken: false
#   volumes:
#   - name: serviceaccount-token
#     projected:
#       defaultMode: 0444
#       sources:
#       - serviceAccountToken:
#           expirationSeconds: 3607
#           path: token
#       - configMap:
#           name: kube-root-ca.crt
#           items:
#           - key: ca.crt
#             path: ca.crt
#       - downwardAPI:
#           items:
#           - path: namespace
#             fieldRef:
#               apiVersion: v1
#               fieldPath: metadata.namespace
#   volumeMounts:
#   - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
#     name: serviceaccount-token
#     readOnly: true

# startupapicheck:
#   automountServiceAccountToken: false
#   serviceAccount:
#     automountServiceAccountToken: false
#   volumes:
#   - name: serviceaccount-token
#     projected:
#       defaultMode: 0444
#       sources:
#       - serviceAccountToken:
#           expirationSeconds: 3607
#           path: token
#       - configMap:
#           name: kube-root-ca.crt
#           items:
#           - key: ca.crt
#             path: ca.crt
#       - downwardAPI:
#           items:
#           - path: namespace
#             fieldRef:
#               apiVersion: v1
#               fieldPath: metadata.namespace
#   volumeMounts:
#   - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
#     name: serviceaccount-token
#     readOnly: true
