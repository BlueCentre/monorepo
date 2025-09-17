# Skaffold Usage Guide

This document provides guidance on using Skaffold with the Template FastAPI Application, covering common development workflows and specific features like rate limiting testing.

## Common Skaffold Commands

### Development Mode

```bash
# Start development mode with the default profile
skaffold dev -m template-fastapi-app

# Development mode with custom profile
skaffold dev -m template-fastapi-app -p dev
```

### Deployment

```bash
# Deploy the application
skaffold run -m template-fastapi-app

# Deploy with a specific profile
skaffold run -m template-fastapi-app -p dev
```

### Verification

```bash
# Verify after deployment
skaffold verify -m template-fastapi-app

# Verify with a specific profile
skaffold verify -m template-fastapi-app -p api-verify-only
```

## Testing Rate Limiting with Skaffold

The application includes dedicated Skaffold profiles for testing Istio-based rate limiting. The recommended approach uses Skaffold custom actions for a fully integrated workflow.

### Rate Limiting with Custom Actions (Recommended)

```bash
# Deploy with integrated Istio setup and verification
skaffold run -m template-fastapi-app -p istio-rate-limit-actions
```

This approach leverages Skaffold's custom actions to:
1. Enable Istio injection on the namespace (pre-deploy action)
2. Deploy the application with all rate limiting configurations
3. Run a verification job and display results (post-deploy action)

For development with live updates:

```bash
skaffold dev -m template-fastapi-app -p istio-rate-limit-actions
```

### Alternative: Manual Workflow

For environments where custom actions aren't supported, you can use this alternative workflow:

```bash
# Step 1: Enable Istio injection manually
kubectl label namespace template-fastapi-app istio-injection=enabled --overwrite

# Step 2: Deploy with rate limiting configurations
skaffold run -m template-fastapi-app -p istio-rate-limit-complete

# Step 3: Check verification results
kubectl logs -n template-fastapi-app -l job-name=rate-limit-test --follow
```

### Manual Rate Limit Testing

After deployment, you can manually test rate limiting:

```bash
# Set up port forwarding
kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80

# In another terminal, send multiple requests to hit the rate limit
for i in {1..50}; do 
  echo "Request $i:"
  curl -i http://localhost:8000/api/v1/users/
  echo "---------------------------------------"
  sleep 0.1
done
```

## Benefits of Custom Actions

Using custom actions for Istio rate limiting provides several advantages:

1. **Integrated Workflow**: Everything runs as part of the Skaffold lifecycle
2. **Simplified Commands**: Single command for the complete workflow
3. **Proper Sequencing**: Actions execute in the right order automatically
4. **Development-Friendly**: Works with both `run` and `dev` commands
5. **Maintainability**: Configuration is declarative and lives with the project

## Troubleshooting

If you encounter issues with the rate limiting verification:

1. Check if Istio is properly installed:
   ```bash
   kubectl get namespace istio-system
   ```

2. Verify the namespace has Istio injection enabled:
   ```bash
   kubectl get namespace template-fastapi-app -o yaml | grep istio-injection
   ```

3. Check the status of all rate limiting components:
   ```bash
   kubectl get all -n template-fastapi-app -l app=ratelimit
   ```

4. Restart the deployment after enabling Istio (if needed):
   ```bash
   kubectl rollout restart deployment template-fastapi-app -n template-fastapi-app
   ```

5. View the verification job logs:
   ```bash
   kubectl logs -n template-fastapi-app -l job-name=rate-limit-test
   ``` 