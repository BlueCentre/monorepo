# Istio Rate Limiting Deployment Guide

This guide outlines how to deploy the FastAPI application with and without Istio rate limiting using Skaffold profiles and Kubernetes jobs.

## Overview

We've implemented a comprehensive rate limiting solution using Istio service mesh that:

1. Protects API endpoints from abuse
2. Applies different rate limits to different endpoints
3. Handles authenticated vs. unauthenticated requests differently
4. Provides monitoring and metrics for rate limiting events

## Prerequisites

- Kubernetes cluster with kubectl configured
- Skaffold installed
- Bazel installed
- For Istio deployment: Istio installed on the cluster

## Deployment Options

### 1. Standard Deployment (Without Istio)

This deployment method works in all Kubernetes environments regardless of whether Istio is installed:

```bash
# Deploy using the dev profile
skaffold run -m template-fastapi-app -p dev
```

This will:
1. Build the application container using Bazel
2. Deploy the application with standard Kubernetes resources
3. Set up the database and run migrations
4. Configure basic networking without rate limiting

### 2. Deployment with Istio Rate Limiting

To deploy with Istio rate limiting, use the dedicated Skaffold profiles:

```bash
# Step 1: Deploy Istio system resources
skaffold run -m istio-system-resources

# Step 2: Deploy the application with Istio rate limiting
skaffold run -m template-fastapi-app -p istio-rate-limit

# Step 3: Verify rate limiting functionality
skaffold verify -m template-fastapi-app -p istio-rate-limit
```

This will:
1. Deploy the application with standard Kubernetes resources
2. Enable Istio injection on the namespace using a Kubernetes job
3. Deploy Istio rate limiting configurations
4. Set up the rate limiting service and Redis backend
5. Configure the virtual service with rate limiting rules

## Development Workflow

For active development with live-reload:

```bash
# For standard development without Istio:
skaffold dev -m template-fastapi-app -p dev

# For development with Istio rate limiting:
# Step 1: Deploy Istio system resources
skaffold run -m istio-system-resources

# Step 2: Deploy the application with Istio rate limiting
skaffold run -m template-fastapi-app -p istio-rate-limit

# Step 3: Start development mode
skaffold dev -m template-fastapi-app -p dev
```

Note that when using `skaffold dev` after enabling Istio, the live reload will update your application code, but changes to Istio configurations will require redeploying with the istio-rate-limit profile.

## How Rate Limiting Works

Our implementation uses Istio's EnvoyFilter resources to configure rate limiting:

1. **Request Classification**: Requests are classified based on path, authentication status, and other attributes
2. **Rate Limit Service**: A dedicated rate limit service tracks request counts
3. **Redis Backend**: Redis stores the rate limit counters
4. **EnvoyFilter Configuration**: Envoy proxies enforce the rate limits

### Rate Limit Configuration

The rate limits are defined in `kubernetes/istio/rate-limiting.yaml`:

```yaml
# Example rate limit configuration
descriptors:
  - key: path
    value: "/api/v1/items"
    rate_limit:
      unit: minute
      requests_per_unit: 5
  - key: path
    value: "/docs"
    rate_limit:
      unit: minute
      requests_per_unit: 10
  - key: path
    rate_limit:
      unit: minute
      requests_per_unit: 100
```

You can modify these values to adjust the rate limits for different endpoints.

## Testing Rate Limiting

To verify that rate limiting is working correctly:

```bash
# Port forward to the application
kubectl port-forward -n template-fastapi-app svc/template-fastapi-app 8000:80

# Make multiple rapid requests to trigger rate limiting
for i in {1..10}; do curl -i localhost:8000/api/v1/items/; sleep 0.1; done
```

With rate limiting enabled, you should see HTTP 429 (Too Many Requests) responses after the configured number of requests.

## Troubleshooting

### Common Issues with Standard Deployment

1. **Application not starting**: Check pod logs with `kubectl logs -n template-fastapi-app deployment/template-fastapi-app`
2. **Database connection issues**: Verify that the postgres pod is running with `kubectl get pods -n template-fastapi-app -l app=postgres`
3. **Build failures**: Check Bazel build logs for errors

### Common Issues with Istio Deployment

1. **Istio not installed**: Install Istio with `istioctl install --set profile=demo`
2. **Rate limiting not working**: Ensure the namespace has Istio injection enabled with `kubectl get namespace template-fastapi-app --show-labels`
3. **429 errors when not expected**: Check the rate limit configuration in `kubernetes/istio/rate-limiting.yaml`
4. **Istio resources not deploying**: Verify that Istio is installed in your cluster

For a comprehensive list of known issues and their resolutions, see the [ISTIO-TROUBLESHOOTING.md](./ISTIO-TROUBLESHOOTING.md) file.

## Monitoring Rate Limiting

To monitor rate limiting events:

```bash
# Check Envoy proxy logs
kubectl logs -n template-fastapi-app deployment/template-fastapi-app -c istio-proxy

# Check rate limit service logs
kubectl logs -n istio-system deployment/ratelimit
```

## Switching Between Modes

To switch from rate-limited mode back to standard mode:

```bash
# Disable Istio rate limiting and redeploy the application
skaffold run -m template-fastapi-app -p disable-istio
```

This will:
1. Disable Istio injection on the namespace using a Kubernetes job
2. Deploy the application without Istio resources

This approach ensures that all validation and setup steps are handled by Kubernetes jobs within the cluster, making it consistent across all environments from local development to CI/CD pipelines.

## DNS Integration with External-DNS

The template application supports automatic DNS record creation for Istio Gateways using external-dns.

### Prerequisites

- External-DNS deployed in your cluster with the following configuration:
  - `--source=istio-gateway` added to the sources
  - Domain filter configured if needed (e.g., `--domain-filter=yourdomain.com`)
  - Proper RBAC permissions to access Istio Gateway resources

### Configuration

The Istio Gateway and VirtualService resources are already configured with the necessary annotations:

```yaml
annotations:
  external-dns.alpha.kubernetes.io/hostname: "your-api-hostname.example.com"
  external-dns.alpha.kubernetes.io/sync-enabled: "true"
```

When you deploy using the `istio-rate-limit` profile, these resources are created and external-dns will automatically create DNS records pointing to your Istio ingress gateway's external IP address.

### Troubleshooting

If DNS records aren't being created:

1. Verify external-dns has `istio-gateway` in its sources:
   ```bash
   kubectl get deployment -n external-dns -o yaml | grep -A 20 args
   ```

2. Check external-dns logs for errors:
   ```bash
   kubectl logs -n external-dns $(kubectl get pods -n external-dns -l app=external-dns -o name | head -n 1)
   ```

3. Confirm the Gateway resource exists and has the proper annotations:
   ```bash
   kubectl get gateway -n template-fastapi-app -o yaml
   ```

For more detailed information about external-dns configuration, see the [EXTERNAL-DNS.md](EXTERNAL-DNS.md) documentation. 