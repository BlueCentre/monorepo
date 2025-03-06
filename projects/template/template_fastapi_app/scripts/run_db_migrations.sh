#!/bin/bash

# Script to run database migrations as a Kubernetes job
set -e

SCRIPT_DIR=$(dirname "$0")
K8S_DIR="$SCRIPT_DIR/../kubernetes"

echo "Starting database migration process..."

# Delete any existing migration jobs to avoid conflicts
kubectl delete job db-migrations -n template-fastapi-app --ignore-not-found=true
if [ $? -ne 0 ]; then
    echo "Warning: Failed to delete existing migration job. Continuing anyway..."
fi

# Apply the migration job
echo "Creating migration job..."
kubectl apply -f "$K8S_DIR/db-migrations-job.yaml"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create migration job."
    exit 1
fi

# Wait for the job to complete
echo "Waiting for migration job to complete..."
kubectl wait --for=condition=complete job/db-migrations -n template-fastapi-app --timeout=60s
if [ $? -ne 0 ]; then
    echo "Error: Migration job did not complete successfully. Checking logs..."
    # Get the pod name for the migration job
    POD_NAME=$(kubectl get pods -n template-fastapi-app -l component=db-migrations -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$POD_NAME" ]; then
        echo "Migration job logs:"
        kubectl logs -n template-fastapi-app "$POD_NAME"
    else
        echo "Cannot find migration pod to display logs."
    fi
    exit 1
fi

echo "Database migration completed successfully." 