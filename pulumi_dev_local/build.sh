#!/bin/bash

# Simple script to build Pulumi configuration by combining component files

# Set up colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Pulumi configuration from components...${NC}"

# Create a clean main.yaml file
cat > main.yaml <<EOF
name: pulumi-dev-local
runtime: yaml
description: Local development environment for Kubernetes using Pulumi

variables:
  region:
    type: string
    default: "us-central1"
  certManagerEnabled:
    type: boolean
    default: true
  openTelemetryEnabled:
    type: boolean
    default: true
  istioEnabled:
    type: boolean
    default: true
  argocdEnabled:
    type: boolean
    default: false
  telepresenceEnabled:
    type: boolean
    default: false
  externalSecretsEnabled:
    type: boolean
    default: false
  externalDnsEnabled:
    type: boolean
    default: false
  datadogEnabled:
    type: boolean
    default: false
  teardown:
    type: boolean
    default: false
  kubernetesContext:
    type: string
    default: "colima"

resources:
EOF

# Add Cert Manager component
echo -e "${YELLOW}Adding Cert Manager component...${NC}"
cat >> main.yaml <<EOF
  # Cert Manager Helm Chart
  certManager:
    type: kubernetes:helm.sh/v3:Release
    properties:
      chart: cert-manager
      version: "v1.17.0"
      repositoryOpts:
        repo: https://charts.jetstack.io
      name: cert-manager
      namespace: cert-manager
      createNamespace: true
      values:
        global:
          leaderElection:
            namespace: cert-manager
        crds:
          enabled: true
          keep: true
        podDisruptionBudget:
          enabled: true
          minAvailable: 1

EOF

# Add OpenTelemetry Operator component
echo -e "${YELLOW}Adding OpenTelemetry Operator component...${NC}"
cat >> main.yaml <<EOF
  # OpenTelemetry Operator Helm Chart
  opentelemetryOperator:
    type: kubernetes:helm.sh/v3:Release
    properties:
      chart: opentelemetry-operator
      version: "0.79.0"
      repositoryOpts:
        repo: https://open-telemetry.github.io/opentelemetry-helm-charts
      name: opentelemetry-operator
      namespace: opentelemetry
      createNamespace: true
      values:
        crds:
          create: true
        manager:
          collectorImage:
            repository: "otel/opentelemetry-collector-k8s"
          leaderElection:
            enabled: true
        admissionWebhooks:
          create: true
          certManager:
            enabled: true
          autoGenerateCert:
            enabled: true
            recreate: true
            certPeriodDays: 365

EOF

# Add OpenTelemetry Collector component
echo -e "${YELLOW}Adding OpenTelemetry Collector component...${NC}"
cat >> main.yaml <<EOF
  # OpenTelemetry Collector Helm Chart
  opentelemetryCollector:
    type: kubernetes:helm.sh/v3:Release
    properties:
      chart: opentelemetry-collector
      version: "0.79.0"
      repositoryOpts:
        repo: https://open-telemetry.github.io/opentelemetry-helm-charts
      name: opentelemetry-collector
      namespace: opentelemetry
      createNamespace: true
      values:
        mode: deployment
        replicaCount: 1
        presets:
          clusterMetrics:
            enabled: true

EOF

# Add Istio Base component
echo -e "${YELLOW}Adding Istio Base component...${NC}"
cat >> main.yaml <<EOF
  # Istio Base Helm Chart
  istioBase:
    type: kubernetes:helm.sh/v3:Release
    properties:
      chart: base
      version: "1.23.3"
      repositoryOpts:
        repo: https://istio-release.storage.googleapis.com/charts
      name: istio-base
      namespace: istio-system
      createNamespace: true
      values:
        base:
          enableIstioConfigCRDs: true
        defaultRevision: default

EOF

# Add Istio CNI component
echo -e "${YELLOW}Adding Istio CNI component...${NC}"
cat >> main.yaml <<EOF
  # Istio CNI Helm Chart
  istioCni:
    type: kubernetes:helm.sh/v3:Release
    properties:
      chart: cni
      version: "1.23.3"
      repositoryOpts:
        repo: https://istio-release.storage.googleapis.com/charts
      name: istio-cni
      namespace: istio-system
      createNamespace: false
      values:
        cniBinDir: "/home/kubernetes/bin"

EOF

# Add Istio Control Plane (istiod) component
echo -e "${YELLOW}Adding Istio Control Plane component...${NC}"
cat >> main.yaml <<EOF
  # Istio Control Plane (istiod) Helm Chart
  istiod:
    type: kubernetes:helm.sh/v3:Release
    properties:
      chart: istiod
      version: "1.23.3"
      repositoryOpts:
        repo: https://istio-release.storage.googleapis.com/charts
      name: istiod
      namespace: istio-system
      createNamespace: false
      values: {}

EOF

# Add Istio Ingress Gateway component
echo -e "${YELLOW}Adding Istio Ingress Gateway component...${NC}"
cat >> main.yaml <<EOF
  # Istio Ingress Gateway Helm Chart
  istioIngressGateway:
    type: kubernetes:helm.sh/v3:Release
    properties:
      chart: gateway
      version: "1.23.3"
      repositoryOpts:
        repo: https://istio-release.storage.googleapis.com/charts
      name: istio-ingressgateway
      namespace: istio-system
      createNamespace: false
      values:
        service:
          type: ClusterIP  # Use ClusterIP for local development
          ports:
            - port: 80
              name: http2
              targetPort: 8080
            - port: 443
              name: https
              targetPort: 8443

EOF

# Add outputs section
cat >> main.yaml <<EOF

outputs:
  status:
    value: "Local development environment is configured with essential Kubernetes components."
  teardown_status:
    value: "Teardown mode enabled, resources will be removed."
    condition: \${teardown}
EOF

echo -e "${GREEN}Configuration built successfully.${NC}"
echo -e "${GREEN}Run 'pulumi preview' to test the configuration.${NC}" 