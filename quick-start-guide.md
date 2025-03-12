# Quick Start Guide: Istio Rate Limiting

This guide shows how to run the application with and without Istio rate limiting. Both scenarios are deployed using Skaffold, the recommended developer workflow tool.

## Prerequisites

1. Kubernetes cluster (local or remote)
2. Docker installed and running
3. Skaffold installed
4. Istio CLI (istioctl) installed

## Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/monorepo.git
cd monorepo
```

## Step 2: Running the Application without Istio

Deploy the application without Istio rate limiting:

```bash
skaffold run -m template-fastapi-app -p dev
```

This will:
- Create the namespace
- Deploy the application
- Deploy the database
- Configure basic networking

Verify the deployment:

```bash
kubectl get pods -n template-fastapi-app
```

Test the application:

```bash
kubectl port-forward -n template-fastapi-app svc/template-fastapi-app 8080:80
curl http://localhost:8080/health
curl http://localhost:8080/api/v1/items
```

You should be able to make unlimited requests to any endpoint without rate limiting.

## Step 3: Running the Application with Istio Rate Limiting

First, undeploy the previous deployment:

```bash
skaffold delete -m template-fastapi-app -p dev
```

Then deploy with Istio rate limiting enabled:

```bash
skaffold run -m template-fastapi-app -p istio-rate-limit
```

This will:
- Create the necessary namespaces
- Install Istio and its components
- Deploy the rate limiting service and Redis
- Deploy the application with Istio sidecar injection
- Configure rate limiting

Verify the deployment:

```bash
kubectl get pods -n template-fastapi-app
kubectl get pods -n istio-system
```

Test the rate limiting:

```bash
./test-rate-limit.sh
```

You should see:
- The `/api/v1/items` endpoint is rate limited (5 requests per minute)
- The `/health` endpoint is not rate limited

## Understanding the Architecture

### Without Istio

```
User -> Kubernetes Service -> Application Pod
```

- Simple Kubernetes deployment
- No rate limiting
- No service mesh features

### With Istio

```
User -> Istio Ingress Gateway -> EnvoyFilter (Rate Limiting) -> Rate Limit Service -> Redis
                              └-> Kubernetes Service -> Application Pod with Istio Sidecar
```

- Service mesh with Istio
- Rate limiting at the gateway level
- Configurable limits per endpoint
- Redis for rate limit counter storage

## Available Skaffold Commands

- Deploy without Istio: `skaffold run -m template-fastapi-app -p dev`
- Deploy with Istio: `skaffold run -m template-fastapi-app -p istio-rate-limit`
- Delete deployment: `skaffold delete -m template-fastapi-app -p <profile>`
- Disable Istio: `skaffold run -m template-fastapi-app -p disable-istio`
- Development mode: `skaffold dev -m template-fastapi-app -p <profile>`

## Modifying Rate Limits

The rate limits are defined in `projects/template/template_fastapi_app/kubernetes/istio/ratelimit-service.yaml`:

```yaml
domain: template-fastapi-rate-limit
descriptors:
  - key: path
    value: "/api/v1/items"
    rate_limit:
      unit: minute
      requests_per_unit: 5
  # Add or modify limits as needed
```

After modifying, reapply with:

```bash
kubectl apply -f projects/template/template_fastapi_app/kubernetes/istio/ratelimit-service.yaml
```

## Troubleshooting

If you encounter issues:

1. Check application pods: `kubectl get pods -n template-fastapi-app`
2. Check Istio components: `kubectl get pods -n istio-system`
3. Check logs: `kubectl logs -n istio-system -l app=ratelimit`
4. Verify ingress: `kubectl get svc -n istio-system istio-ingressgateway`

For more detailed troubleshooting, refer to the README-rate-limiting.md file. 