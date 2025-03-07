#!/bin/bash
# Script to verify Istio rate limiting after deploying via Skaffold
set -e

echo "Verifying Istio rate limiting functionality..."

# Check if the rate-limit-test job already exists and delete it if so
if kubectl get job rate-limit-test -n template-fastapi-app > /dev/null 2>&1; then
  echo "Removing previous rate limit test job..."
  kubectl delete job rate-limit-test -n template-fastapi-app
fi

# Apply the verification job
echo "Creating rate limit verification job..."
kubectl apply -f kubernetes/istio-rate-limit-verify.yaml

# Follow logs from the test
echo "Following logs from the rate limit test..."
kubectl wait --namespace template-fastapi-app --for=condition=complete job/rate-limit-test --timeout=180s || true
kubectl logs -n template-fastapi-app -l job-name=rate-limit-test --follow

# Check if the test was successful
if kubectl get job rate-limit-test -n template-fastapi-app -o jsonpath='{.status.succeeded}' | grep -q "1"; then
  echo "✅ Rate limiting verification completed successfully!"
else
  echo "⚠️ Rate limiting verification did not complete successfully."
  echo "Check the logs for more details."
fi

echo ""
echo "===== Manual Verification Steps ====="
echo "To manually verify rate limiting, run the following commands:"
echo ""
echo "1. Set up port forwarding:"
echo "   kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80"
echo ""
echo "2. In another terminal, send multiple requests to hit the rate limit:"
echo "   for i in {1..50}; do curl -i http://localhost:8000/api/v1/users/; sleep 0.1; done"
echo ""
echo "You should start seeing 429 Too Many Requests responses after several requests."
echo "=========================================" 