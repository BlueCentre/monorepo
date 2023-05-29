# Istio Rate Limiting Setup

This document describes how to set up rate limiting with Istio for Kubernetes applications.

## Overview

Rate limiting is a critical feature for protecting APIs from abuse and ensuring fair usage. This setup uses Istio's EnvoyFilter resources to implement rate limiting based on request paths.

## Components

1. **Istio**: Service mesh that provides traffic management, security, and observability
2. **EnvoyFilter**: Custom Istio resources that configure the Envoy proxy for rate limiting
3. **Ratelimit Service**: A standalone service that implements the rate limiting logic
4. **Redis**: Backend storage for the rate limiting service

## Setup Steps

1. Install Istio with the demo profile:
   ```bash
   istioctl install --set profile=demo --set hub=docker.io/istio --set tag=1.23.3 -y
   ```

2. Enable Istio injection for your namespace:
   ```bash
   kubectl label namespace your-namespace istio-injection=enabled --overwrite
   ```

3. Deploy the rate limiting service and Redis:
   ```bash
   kubectl apply -f ratelimit-service.yaml
   kubectl create deployment redis --image=redis:alpine -n istio-system
   kubectl expose deployment redis --port=6379 -n istio-system
   ```

4. Configure rate limiting with EnvoyFilters:
   ```bash
   kubectl apply -f rate-limiting.yaml
   ```

5. Create Gateway and VirtualService to route traffic:
   ```bash
   kubectl apply -f gateway-vs.yaml
   ```

## Rate Limiting Configuration

The rate limiting is configured in the `ratelimit-config` ConfigMap:

```yaml
domain: template-fastapi-rate-limit
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

This configuration:
- Limits `/api/v1/items` to 5 requests per minute
- Limits `/docs` to 10 requests per minute
- Limits all other paths to 100 requests per minute

## Testing

You can test the rate limiting functionality using the provided script:

```bash
./test-rate-limit.sh
```

The script will:
1. Set up port-forwarding to the Istio ingress gateway
2. Test the rate-limited endpoint (`/api/v1/items`)
3. Test a non-rate-limited endpoint (`/health`)
4. Clean up port-forwarding

## Troubleshooting

If you encounter issues with rate limiting:

1. Check the Istio ingress gateway logs:
   ```bash
   kubectl logs -n istio-system -l istio=ingressgateway
   ```

2. Check the rate limiter service logs:
   ```bash
   kubectl logs -n istio-system -l app=ratelimit
   ```

3. Verify the EnvoyFilter configurations:
   ```bash
   kubectl get envoyfilters -A
   ```

4. Test direct connectivity to the application:
   ```bash
   kubectl port-forward -n your-namespace svc/your-service 8081:80
   curl http://localhost:8081/health
   ```

## Notes

- The rate limiting service uses Redis for storage, so ensure Redis is running correctly
- Rate limiting is applied at the Istio ingress gateway level, not at the application level
- The Host header must be set correctly when accessing the application through the Istio ingress gateway 