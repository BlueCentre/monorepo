# Rate Limiting in Template FastAPI Application

This document describes the multi-layered rate limiting approach implemented in the Template FastAPI Application.

## Overview

Rate limiting is a critical security feature that protects your API from abuse, denial-of-service attacks, and excessive usage. Our application implements a comprehensive, defense-in-depth approach with two independent rate limiting layers:

1. **Application-level rate limiting**: Implemented directly in the FastAPI code using SlowAPI
2. **Infrastructure-level rate limiting**: Implemented using Istio service mesh

This dual-layer approach provides robust protection, as one layer can continue functioning even if the other is bypassed or fails.

## Application-Level Rate Limiting

The application uses the SlowAPI library to implement endpoint-specific rate limiting with different strategies:

### IP-Based Rate Limiting

The `/api/v1/rate-limited/rate-limited` endpoint limits requests to 3 per minute per IP address:

```python
@router.get("/rate-limited", response_model=Dict[str, Any])
@limiter.limit("3/minute")
async def rate_limited_endpoint(
    request: Request,
    response: Response,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Rate-limited endpoint that requires token authentication.
    
    Limited to 3 requests per minute per IP address.
    """
    return {
        "message": "Successfully accessed rate-limited endpoint",
        "user_id": current_user.id,
        "user_email": current_user.email,
    }
```

### User-Based Rate Limiting

The `/api/v1/rate-limited/rate-limited-user` endpoint limits requests to 10 per minute per user ID:

```python
@router.get("/rate-limited-user", response_model=Dict[str, Any])
@limiter.limit("10/minute", key_func=lambda request: request.state.user_id)
async def rate_limited_by_user(
    request: Request,
    response: Response,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Rate-limited endpoint based on the user ID rather than IP address.
    
    Limited to 10 requests per minute per user.
    """
    # Store user ID in request state for rate limiting
    request.state.user_id = str(current_user.id)
    
    return {
        "message": "Successfully accessed user-based rate-limited endpoint",
        "user_id": current_user.id,
        "user_email": current_user.email,
    }
```

### Application Rate Limiting Features

- Rate limits are enforced per endpoint with different strategies
- Rate limits can be based on IP address, user ID, or custom keys
- Different limits can be applied to different endpoints
- Exceeding the rate limit returns HTTP 429 (Too Many Requests) responses
- Memory-efficient implementation with minimal performance impact

## Infrastructure-Level Rate Limiting with Istio

In addition to application-level rate limiting, we implement infrastructure-level rate limiting using Istio service mesh. This approach:

1. Enforces rate limits at the proxy layer (outside the application)
2. Uses Redis for distributed rate limiting (supporting multiple replicas)
3. Can be configured without application code changes

### Istio Rate Limiting Components

The Istio-based rate limiting solution consists of:

1. **EnvoyFilters**: Custom Istio resources that configure the Envoy proxy for rate limiting
2. **Redis**: Backend storage for rate limit counters
3. **Rate Limit Descriptors**: Configuration that defines the rate limit rules

### EnvoyFilter Resources

Several EnvoyFilter resources work together to implement rate limiting:

#### 1. Path Extractor
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: rate-limit-path-extractor
spec:
  workloadSelector:
    labels:
      app: template-fastapi-app
  configPatches:
    - applyTo: HTTP_FILTER
      patch:
        operation: INSERT_BEFORE
        value:
          name: envoy.filters.http.ratelimit
          typed_config:
            "@type": "type.googleapis.com/envoy.extensions.filters.http.ratelimit.v3.RateLimit"
            domain: "template-fastapi-app-domain"
            # ... configuration continues
```

#### 2. Authentication Extractor
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: rate-limit-auth-extractor
spec:
  configPatches:
    - applyTo: HTTP_ROUTE
      patch:
        operation: MERGE
        value:
          route:
            rate_limits:
              - actions:
                  # Extract path from the request URL
                  - request_headers:
                      header_name: ":path"
                      descriptor_key: "path"
                  # Check authentication status
                  - request_headers:
                      header_name: "authorization"
                      descriptor_key: "auth"
                      descriptor_value: "authenticated"
```

#### 3. Specific Endpoint Rate Limit
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: rate-limit-specific-endpoint
spec:
  configPatches:
    - applyTo: HTTP_ROUTE
      match:
        routeConfiguration:
          vhost:
            route:
              path: "/api/v1/rate-limited/rate-limited"
      patch:
        operation: MERGE
        value:
          route:
            rate_limits:
              - actions:
                  - request_headers:
                      header_name: ":path"
                      descriptor_key: "path"
                  - generic_key:
                      descriptor_value: "/api/v1/rate-limited/rate-limited"
```

### Redis Backend Integration

The rate limiting system uses Redis as a backend storage for rate limit counters. This is configured in the infrastructure via:

1. **Terraform**: For infrastructure deployed with Terraform
   ```hcl
   resource "kubernetes_manifest" "rate_limit_service" {
     manifest = {
       apiVersion = "networking.istio.io/v1alpha3"
       kind       = "EnvoyFilter"
       metadata = {
         name      = "rate-limit-service"
         namespace = "istio-system"
       }
       spec = {
         # ... configuration continues
         value = {
           socket_address = {
             address   = "redis-master.redis.svc.cluster.local"
             port_value = 6379
           }
         }
       }
     }
   }
   ```

2. **Pulumi**: For infrastructure deployed with Pulumi
   ```go
   _, err = resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
     Name: "istio-rate-limit-service",
     YAML: `apiVersion: networking.istio.io/v1alpha3
   kind: EnvoyFilter
   metadata:
     name: rate-limit-service
     namespace: istio-system
   spec:
     # ... configuration continues
     value:
       socket_address:
         address: redis-master.redis.svc.cluster.local
         port_value: 6379
   `})
   ```

## Infrastructure Requirements

To use the rate limiting features, you need:

1. **Istio Service Mesh**: Installed in the cluster with version 1.23.3 or later
2. **Redis**: Deployed in the `redis` namespace with a service name of `redis-master`
3. **EnvoyFilters**: The rate limiting EnvoyFilters configured in the Istio installation

## Deploying with Rate Limiting

Use the Skaffold profile for Istio rate limiting:

```bash
# Deploy the application with Istio rate limiting enabled
skaffold run -m template-fastapi-app -p istio-rate-limit

# Verify rate limiting functionality
skaffold verify -m template-fastapi-app -p istio-rate-limit
```

## Testing Rate Limiting

The verification script sends multiple rapid requests to test rate limiting:

```bash
# This is done automatically by skaffold verify, but you can test manually:
for i in {1..6}; do 
  curl -i http://template-fastapi-app.template-fastapi-app.svc.cluster.local/api/v1/rate-limited/rate-limited \
  -H "Authorization: Bearer $TOKEN"
done
```

With proper configuration, you should see:
- The first 3 requests succeed with HTTP 200
- Subsequent requests fail with HTTP 429 (Too Many Requests)

## Troubleshooting

### Application-Level Rate Limiting Issues

1. **Rate limiting not working**: Check that SlowAPI is properly installed and configured
2. **Different limits than expected**: Verify the `@limiter.limit()` decorators on your endpoints

### Istio-Level Rate Limiting Issues

1. **EnvoyFilters not applied**: Check that the EnvoyFilters are deployed:
   ```bash
   kubectl get envoyfilters -n istio-system
   ```

2. **Redis not working**: Verify Redis is running:
   ```bash
   kubectl get pods -n redis
   ```

3. **Rate limiting not triggering**: Check the Envoy proxy logs:
   ```bash
   kubectl logs -n template-fastapi-app deployment/template-fastapi-app -c istio-proxy
   ```

## Customizing Rate Limits

### Modifying Application-Level Limits

Edit the rate limit decorators in `app/api/v1/endpoints/rate_limited.py`:

```python
# Change from 3 to 5 requests per minute
@limiter.limit("5/minute")
```

### Modifying Istio-Level Limits

The Istio rate limits are defined in the EnvoyFilter resources. To modify them:

1. Edit the `projects/template/template_fastapi_app/kubernetes/istio/rate-limit-handler.yaml` file
2. Apply the changes by redeploying with Skaffold:
   ```bash
   skaffold run -m template-fastapi-app -p istio-rate-limit
   ```

## Conclusion

This multi-layered rate limiting approach provides robust protection for your API:

1. **Defense in Depth**: Two independent rate limiting mechanisms
2. **Flexibility**: Different rate limiting strategies for different endpoints
3. **Scalability**: Redis-backed infrastructure-level rate limiting supports horizontal scaling
4. **Separation of Concerns**: Application developers can focus on business logic while infrastructure teams can manage global rate limits

By combining application-level and infrastructure-level rate limiting, the Template FastAPI Application provides comprehensive protection against API abuse. 