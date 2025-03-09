# Istio Rate Limiting Deployment Guide

This guide outlines how to deploy the FastAPI application with and without Istio rate limiting using Skaffold profiles and Kubernetes jobs.

## Overview

We've implemented two deployment approaches using Skaffold profiles that use Kubernetes jobs for setup and verification:

1. **Standard Deployment (No Istio)** - For environments without Istio or where rate limiting is not needed
2. **Istio Rate Limiting Deployment** - For environments with Istio installed, enabling API rate limiting

## Prerequisites

- Kubernetes cluster with kubectl configured
- For Istio deployment: Istio installed on the cluster (use `istioctl install --set profile=demo` if not installed)
- Bazel and Skaffold installed

## Deployment Options

### 1. Standard Deployment (Without Istio)

This deployment method works in all Kubernetes environments regardless of whether Istio is installed:

```bash
# Deploy using the no-istio profile
skaffold run -m template-fastapi-app -p no-istio --filename=skaffold-refactored.yaml
```

This will:
1. Deploy the setup job that prepares the environment (removing Istio injection if needed)
2. Deploy the application without Istio-related resources
3. Deploy the verification job that validates the deployment

### 2. Deployment with Istio Rate Limiting

This deployment method requires Istio to be installed in your cluster:

```bash
# Deploy using the istio-rate-limit profile
skaffold run -m template-fastapi-app -p istio-rate-limit --filename=skaffold-refactored.yaml
```

This will:
1. Deploy the setup job that enables Istio injection on the namespace
2. Deploy the application with all Istio rate limiting configurations
3. Deploy the verification job that validates rate limiting functionality

## How It Works

Our implementation uses standard Kubernetes jobs to handle setup and verification, which are deployed as part of the Skaffold deployment process:

### Setup Jobs

For Istio deployment:
- `kubernetes/istio-setup-job.yaml`: Creates a job that enables Istio injection on the namespace

For standard deployment:
- `kubernetes/standard-setup-job.yaml`: Creates a job that disables Istio injection (if enabled) and cleans up any leftover Istio resources

### Verification Jobs

For Istio deployment:
- `kubernetes/verify-rate-limit-job.yaml`: Creates a job that verifies rate limiting is working properly

For standard deployment:
- `kubernetes/verify-standard-job.yaml`: Creates a job that verifies the basic functionality of the application

### ConfigMaps

Both approaches use ConfigMaps to provide the verification job YAML files:
- `kubernetes/istio-configmaps.yaml`: Contains the YAML definitions for the verification jobs

## Troubleshooting

### Common Issues with Standard Deployment

1. **Namespace already exists**: Safe to ignore, the setup job continues
2. **No Istio resources found**: Safe to ignore if deploying without Istio
3. **Verification fails**: Check pod logs with `kubectl logs -n template-fastapi-app job/verify-standard-deployment`

### Common Issues with Istio Deployment

1. **Istio not installed**: The setup job will print warnings, install Istio with `istioctl install --set profile=demo`
2. **Rate limiting verification fails**: Check logs with `kubectl logs -n template-fastapi-app job/verify-rate-limiting`
3. **Redis pod not ready**: Check Redis status with `kubectl get pods -n template-fastapi-app -l app=redis`

## Testing Rate Limiting Manually

To manually test rate limiting:
```bash
# Forward the application port
kubectl port-forward -n template-fastapi-app svc/template-fastapi-app 8000:80

# Make multiple rapid requests to trigger rate limiting
for i in {1..50}; do curl -i localhost:8000/api/v1/users/; sleep 0.1; done
```

You should see HTTP 429 (Too Many Requests) responses after several requests if rate limiting is working correctly.

## Development Workflow

For active development with live-reload:

```bash
# For standard development without Istio:
skaffold dev -m template-fastapi-app -p no-istio --filename=skaffold-refactored.yaml

# For development with Istio rate limiting:
skaffold dev -m template-fastapi-app -p istio-rate-limit --filename=skaffold-refactored.yaml
```

This approach ensures that all validation and setup steps are handled by Kubernetes jobs within the cluster, making it consistent across all environments from local development to CI/CD pipelines. 