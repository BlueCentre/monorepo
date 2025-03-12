# Istio Rate Limiting Troubleshooting Guide

This document tracks known issues with the Istio rate limiting implementation and verification in the template-fastapi-app.

## Issue 1: Missing Istio Control Plane Components

**Problem:** The Istio CRDs are installed and the EnvoyFilter resources for rate limiting are deployed in the istio-system namespace, but there are no actual Istio control plane components running.

**Impact:**
- Istio injection is not working (no pods have istio-proxy sidecars)
- Rate limiting functionality cannot work without the Istio control plane
- EnvoyFilters are deployed but have nothing to apply to

**Verification:**
```bash
# Check if Istio pods are running
kubectl get pods -n istio-system
# Result: No resources found in istio-system namespace

# Check if pods have Istio sidecars
kubectl get pods -n template-fastapi-app -o jsonpath='{.items[*].spec.containers[*].name}' | grep istio-proxy
# Result: No output (no istio-proxy containers)
```

**Resolution Steps:**
1. Deploy the Istio control plane components:
   ```bash
   istioctl install --set profile=demo
   ```
2. Verify the Istio control plane is running:
   ```bash
   kubectl get pods -n istio-system
   ```

## Issue 2: Namespace Label for Istio Injection

**Problem:** The namespace doesn't have the `istio-injection=enabled` label, which is required for Istio to automatically inject sidecars into pods.

**Impact:**
- Pods are deployed without Istio sidecars
- Rate limiting cannot be applied without the Istio sidecar

**Verification:**
```bash
# Check if the namespace has the Istio injection label
kubectl get namespace template-fastapi-app --show-labels
# Result: No istio-injection=enabled label
```

**Resolution Steps:**
1. Enable Istio injection on the namespace:
   ```bash
   kubectl label namespace template-fastapi-app istio-injection=enabled --overwrite
   ```
2. Restart the application pods to get Istio sidecars:
   ```bash
   kubectl rollout restart deployment template-fastapi-app -n template-fastapi-app
   ```
3. Verify pods have Istio sidecars:
   ```bash
   kubectl get pods -n template-fastapi-app -o jsonpath='{.items[*].spec.containers[*].name}' | grep istio-proxy
   ```

## Issue 3: Rate Limiting Services Not Deployed

**Problem:** The rate limiting services (ratelimit and redis) are not deployed in the istio-system namespace.

**Impact:**
- There's nothing to enforce the rate limits even if Istio was working

**Verification:**
```bash
# Check if rate limiting services are deployed
kubectl get svc -n istio-system
# Result: No resources found in istio-system namespace
```

**Resolution Steps:**
1. Deploy the rate limiting services:
   ```bash
   kubectl apply -f kubernetes/istio/rate-limiting.yaml -n istio-system
   ```
2. Verify the services are running:
   ```bash
   kubectl get svc -n istio-system
   kubectl get deployment -n istio-system
   ```

## Issue 4: Redirect Issue in the API Endpoint

**Problem:** The verification script is trying to access `/api/v1/items` but the API is redirecting to `/api/v1/items/` (with a trailing slash).

**Impact:**
- The script is not following redirects, so it's not seeing the 401 Unauthorized response that would indicate the service is working

**Verification:**
```bash
# Test the API endpoint without following redirects
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- curl -v http://template-fastapi-app.template-fastapi-app/api/v1/items
# Result: HTTP/1.1 307 Temporary Redirect

# Test the API endpoint with following redirects
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- curl -L -v http://template-fastapi-app.template-fastapi-app/api/v1/items
# Result: HTTP/1.1 401 Unauthorized (after following redirect)
```

**Resolution Steps:**
1. Modify the verification script to either:
   - Use the correct URL with the trailing slash: `/api/v1/items/`
   - Add `-L` to the curl command to follow redirects
   - Include 307 in the list of acceptable response codes

## Issue 5: Verification Script Not Handling Redirects

**Problem:** The verification script is checking for specific status codes (200, 401, 403, 429) but not handling 307 Temporary Redirect responses.

**Impact:**
- The script cannot find a working service URL because it's not recognizing the 307 response as valid

**Verification:**
```bash
# Check the verification script logic
grep -A 5 "response=" projects/template/template_fastapi_app/skaffold.yaml
# Result: if [ "$response" = "200" ] || [ "$response" = "401" ] || [ "$response" = "403" ] || [ "$response" = "429" ]; then
```

**Resolution Steps:**
1. Update the verification script to include 307 in the list of acceptable response codes:
   ```bash
   if [ "$response" = "200" ] || [ "$response" = "401" ] || [ "$response" = "403" ] || [ "$response" = "429" ] || [ "$response" = "307" ]; then
   ```
2. Or modify the script to use curl with the `-L` flag to follow redirects

## Complete Verification Workflow

After addressing all the issues above, follow this workflow to verify that rate limiting is working correctly:

1. Deploy Istio control plane:
   ```bash
   istioctl install --set profile=demo
   ```

2. Deploy the application with Istio rate limiting:
   ```bash
   skaffold run -m template-fastapi-app -p istio-rate-limit
   ```

3. Verify that Istio injection is enabled:
   ```bash
   kubectl get namespace template-fastapi-app --show-labels
   # Should show istio-injection=enabled
   ```

4. Verify that pods have Istio sidecars:
   ```bash
   kubectl get pods -n template-fastapi-app
   # READY column should show 2/2 for application pods
   ```

5. Verify that rate limiting services are deployed:
   ```bash
   kubectl get pods -n istio-system
   # Should show ratelimit and redis pods
   ```

6. Test rate limiting manually:
   ```bash
   # Port forward to the service
   kubectl port-forward -n template-fastapi-app svc/template-fastapi-app 8000:80
   
   # Make multiple rapid requests to trigger rate limiting
   for i in {1..20}; do curl -i -L localhost:8000/api/v1/items; sleep 0.1; done
   # Should see HTTP 429 Too Many Requests after several requests
   ```

7. Run the verification job:
   ```bash
   skaffold verify -m template-fastapi-app -p istio-rate-limit
   ``` 