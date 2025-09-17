# Configuration for the CloudNativePG operator
# See https://github.com/cloudnative-pg/charts/blob/main/charts/cloudnative-pg/values.yaml

crds:
  create: true

# Set to false to install the operator in a specific namespace only
config:
  clusterWide: true

# Webhook configuration
webhook:
  timeoutSeconds: 60
  certManager:
    enabled: true

# SecurityContext for the operator pod
securityContext:
  runAsNonRoot: true
  runAsUser: 65534
  runAsGroup: 65534

# PodSecurityContext for the operator pod
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 65534
  fsGroup: 65534

# Prometheus metrics configuration
metrics:
  # Enable metrics collection
  enabled: true
  serviceMonitor:
    # Enables ServiceMonitor creation for Prometheus Operator
    enabled: false

# Operator resource requests and limits
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi 