# Bitnami MongoDB Helm Chart Values
# https://github.com/bitnami/charts/blob/main/bitnami/mongodb/values.yaml

global:
  imageRegistry: ""
  imagePullSecrets: []
  storageClass: ""

# Custom labels for all resources
commonLabels:
  app.kubernetes.io/part-of: "platform-infrastructure"
  app.kubernetes.io/managed-by: "terraform"

# Authentication configuration
auth:
  enabled: true
  # rootPassword will be provided by terraform variables
  # rootUser is admin by default
  replicaSetKey: ""
  existingSecret: ""

# Architecture configuration
architecture: replicaset # Can be standalone or replicaset
replicaCount: 1 # Requested 1 replica

# MongoDB configuration
arbiter:
  enabled: false # Disabling arbiter since we only need 1 replica

# Persistence configuration
persistence:
  enabled: true
  mountPath: /bitnami/mongodb
  size: 8Gi
  storageClass: ""

# Service configuration
service:
  type: ClusterIP
  port: 27017
  portName: mongodb
  nodePort: ""
  clusterIP: ""
  annotations:
    app.kubernetes.io/purpose: "application-db"

# Network policies
networkPolicy:
  enabled: true
  allowExternal: true

# MongoDB metrics using Prometheus exporter
metrics:
  enabled: true
  serviceMonitor:
    enabled: false
    additionalLabels: {}
    namespace: ""
    interval: 30s
    scrapeTimeout: 10s

# Resources configuration
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "1Gi"
    cpu: "500m"

# Pod security context
podSecurityContext:
  enabled: true
  fsGroup: 1001

# Container security context
containerSecurityContext:
  enabled: true
  runAsUser: 1001

# RBAC configuration
rbac:
  create: true

# Readiness/liveness probes
livenessProbe:
  enabled: true
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
  successThreshold: 1

readinessProbe:
  enabled: true
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
  successThreshold: 1

# TLS configuration
tls:
  enabled: false 