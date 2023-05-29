# https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/values.yaml

mode: ${mode}

# image:
#   repository: "otel/opentelemetry-collector-k8s"

replicaCount: 1

presets:
  clusterMetrics:
    enabled: true
