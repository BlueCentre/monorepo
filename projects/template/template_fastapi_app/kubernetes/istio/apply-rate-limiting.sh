#!/bin/bash

# Apply rate limiting EnvoyFilters directly to istio-system namespace
echo "Applying rate limiting configuration to istio-system namespace..."
kubectl apply -f $(dirname "$0")/rate-limiting.yaml --namespace=istio-system

echo "Rate limiting configuration applied." 