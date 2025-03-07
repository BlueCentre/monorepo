#!/bin/bash
# Script to deploy and test Istio rate limiting
set -e

# Change to the project root directory
cd "$(dirname "$0")"

# Check if Istio is installed
if ! kubectl get namespace istio-system &>/dev/null; then
  echo "Istio namespace not found. Istio must be installed in the cluster."
  echo "Please install Istio first or check your Kubernetes connection."
  exit 1
fi

# Deploy the application with Istio rate limiting
echo "Deploying the application with Istio rate limiting..."
skaffold run -m template-fastapi-app

# Wait for the deployment to be ready
echo "Waiting for the application deployment to be ready..."
kubectl wait --namespace template-fastapi-app --for=condition=available deployment/template-fastapi-app --timeout=180s || true

# Apply Istio injection label to the namespace
echo "Enabling Istio sidecar injection for the namespace..."
kubectl label namespace template-fastapi-app istio-injection=enabled --overwrite

# Restart the deployment to ensure Istio sidecar injection
echo "Restarting the deployment to ensure Istio sidecar injection..."
kubectl rollout restart deployment template-fastapi-app -n template-fastapi-app

# Apply Istio rate limiting configurations
echo "Applying Istio rate limiting configurations..."
kubectl apply -f kubernetes/istio-rate-limit.yaml -n template-fastapi-app
kubectl apply -f kubernetes/istio-virtual-service.yaml -n template-fastapi-app
kubectl apply -f kubernetes/istio-rate-limit-handler.yaml -n template-fastapi-app

# Wait for the deployment to be ready again
echo "Waiting for the deployment to be ready again..."
kubectl wait --namespace template-fastapi-app --for=condition=available deployment/template-fastapi-app --timeout=180s || true
kubectl wait --namespace template-fastapi-app --for=condition=available deployment/ratelimit --timeout=180s || true

# Run the rate limit test
echo "Running the rate limit test..."
kubectl apply -f kubernetes/istio-ratelimit-test.yaml

# Follow logs from the test
echo "Following logs from the rate limit test..."
kubectl wait --namespace template-fastapi-app --for=condition=complete job/rate-limit-test --timeout=180s || true
kubectl logs -n template-fastapi-app -l job-name=rate-limit-test --follow

# Check if the test was successful
if kubectl get job rate-limit-test -n template-fastapi-app -o jsonpath='{.status.succeeded}' | grep -q "1"; then
  echo "✅ Rate limiting test completed successfully!"
else
  echo "⚠️ Rate limiting test did not complete successfully."
  echo "Check the logs for more details."
fi

# Instructions for manual testing
echo ""
echo "===== Manual Testing Instructions ====="
echo "To test rate limiting manually, run the following commands:"
echo ""
echo "1. Set up port forwarding:"
echo "   kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80"
echo ""
echo "2. In another terminal, send multiple requests to hit the rate limit:"
echo "   for i in {1..50}; do curl -i http://localhost:8000/api/v1/users/; sleep 0.1; done"
echo ""
echo "You should start seeing 429 Too Many Requests responses after several requests."
echo "=========================================" 