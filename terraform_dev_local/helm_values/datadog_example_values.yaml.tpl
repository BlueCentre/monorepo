# https://github.com/DataDog/helm-charts/blob/main/charts/datadog/values.yaml

targetSystem: "linux"
providers:
  gke:
    autopilot: true
datadog:
  apiKeyExistingSecret: datadog
  appKeyExistingSecret: datadog
  collectEvents: false
  # https://app.datadoghq.com/infrastructure?netviz=sent_vol%3A%3A%2Ctcp_r_pct%3A%3A%2Crtt%3A%3A&tab=logs&text=example_tenant%3Ademo
  tags:
    - example_tenant:demo
    - example_owner:platform
    - env:dev
  containerExclude: "kube_namespace:.*"
  containerInclude: "kube_namespace:composer-.* name:airflow-worker.*"
  logs:
    enabled: true
    containerCollectAll: true
    autoMultiLineDetection: true
  apm:
    portEnabled: true
clusterAgent:
  enabled: true
  admissionController:
    enabled: true
    requests:
        cpu: 150m
        memory: 300Mi
kube-state-metrics:
  resources:
    requests:
        cpu: 150m
        memory: 300Mi
clusterChecksRunner:
  resources:
    requests:
      cpu: 150m
      memory: 300Mi
agents:
  containers:
    initContainers:
      resources:
        requests:
          cpu: 150m
          memory: 300Mi
    securityAgent:
      resources:
        requests:
            cpu: 150m
            memory: 300Mi
    systemProbe:
      resources:
        requests:
            cpu: 150m
            memory: 300Mi
    traceAgent:
      resources:
        requests:
            cpu: 150m
            memory: 300Mi
    processAgent:
      resources:
        requests:
            cpu: 150m
            memory: 300Mi
    agent:
      readinessProbe:
        initialDelaySeconds: 60
        periodSeconds: 30
        timeoutSeconds: 5
        successThreshold: 1
        failureThreshold: 6
      resources:
        requests:
            cpu: 150m
            memory: 300Mi
