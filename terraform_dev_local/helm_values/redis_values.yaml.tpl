# Bitnami Redis Helm Chart Values
# https://github.com/bitnami/charts/blob/main/bitnami/redis/values.yaml

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
  sentinel: false
  usePasswordFiles: false

# Redis master configuration
master:
  persistence:
    enabled: true
    medium: ""
    path: /data
    size: 8Gi
    storageClass: ""
  service:
    type: ClusterIP
    ports:
      redis: 6379
    annotations:
      app.kubernetes.io/purpose: "multi-tenant"
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "1Gi"
      cpu: "500m"

# Redis replica configuration
replica:
  replicaCount: 1
  persistence:
    enabled: true
    size: 8Gi
  service:
    type: ClusterIP
    ports:
      redis: 6379
    annotations:
      app.kubernetes.io/purpose: "multi-tenant"
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "1Gi"
      cpu: "500m"

# Sentinel configuration if needed for high availability
sentinel:
  enabled: false
  masterSet: mymaster

# Metrics using the Prometheus exporter
metrics:
  enabled: true
  serviceMonitor:
    enabled: false

# Network policies
networkPolicy:
  enabled: true
  # Allow connections from all namespaces
  allowExternal: true
  # Additional network policy as needed
  ingressNSMatchLabels: {}
  ingressNSPodMatchLabels: {}

# Additional parameters for tuning
commonConfiguration: |-
  # Enable AOF https://redis.io/topics/persistence#append-only-file
  appendonly yes
  # Disable RDB persistence
  save "" 