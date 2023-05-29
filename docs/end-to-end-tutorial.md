# End-to-End Infrastructure and Application Deployment Tutorial

This tutorial walks you through the complete process of:
1. Setting up the local Kubernetes infrastructure using either Terraform or Pulumi
2. Deploying a sample application that utilizes the infrastructure components
3. Testing the application with the infrastructure features

## Prerequisites

Before starting this tutorial, ensure you have the following tools installed:

- [Docker](https://www.docker.com/get-started)
- [Colima](https://github.com/abiosoft/colima) (for local Kubernetes)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)
- One of the following:
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v1.0+)
  - [Pulumi](https://www.pulumi.com/docs/get-started/install/) (v3.0+) and [Go](https://golang.org/doc/install) (v1.18+)
- [Skaffold](https://skaffold.dev/docs/install/) (v2.0+)
- [Git](https://git-scm.com/downloads)

## Part 1: Setting Up Local Kubernetes

First, we need to set up a local Kubernetes cluster using Colima:

```bash
# Start Colima with Kubernetes enabled
colima start --kubernetes --cpu 4 --memory 8

# Verify Kubernetes is running
kubectl get nodes
```

## Part 2: Deploying Infrastructure Components

Next, we'll deploy the necessary infrastructure components. Choose either Terraform or Pulumi based on your preference.

### Option A: Using Terraform

```bash
# Navigate to the Terraform directory
cd terraform_dev_local

# Initialize Terraform
terraform init

# Apply the configuration with required components
# Edit terraform.auto.tfvars first to enable/disable components
cat > terraform.auto.tfvars << EOF
kubernetes_context = "colima"
region = "us-central1"

# Enable required components
cert_manager_enabled = true
external_secrets_enabled = true
istio_enabled = true
redis_enabled = true
cnpg_enabled = true

# Set passwords (for local development only)
redis_password = "local-dev-password"
cnpg_app_db_password = "local-pg-password"
EOF

# Apply the configuration
terraform apply -auto-approve
```

### Option B: Using Pulumi

```bash
# Navigate to the Pulumi directory
cd pulumi_dev_local

# Initialize Pulumi stack (if needed)
pulumi stack init dev

# Configure required components
pulumi config set dev-local-infrastructure:kubernetes_context colima
pulumi config set dev-local-infrastructure:cert_manager_enabled true
pulumi config set dev-local-infrastructure:external_secrets_enabled true
pulumi config set dev-local-infrastructure:istio_enabled true
pulumi config set dev-local-infrastructure:redis_enabled true
pulumi config set dev-local-infrastructure:cnpg_enabled true

# Set passwords (for local development only)
pulumi config set dev-local-infrastructure:redis_password "local-dev-password" --secret
pulumi config set dev-local-infrastructure:cnpg_app_db_password "local-pg-password" --secret

# Deploy the infrastructure
pulumi up -y
```

## Part 3: Verifying Infrastructure Deployment

Let's verify that all components are running correctly:

```bash
# Check Istio components
kubectl get pods -n istio-system

# Check Cert Manager
kubectl get pods -n cert-manager

# Check CloudNative PG
kubectl get pods -n cnpg-system

# Check Redis
kubectl get pods -n redis
```

All pods should be in the `Running` state with status `Ready`.

## Part 4: Deploying a Sample Application

Now, we'll deploy a sample application that utilizes the infrastructure components.

```bash
# Navigate to the template FastAPI application
cd ../projects/template/template_fastapi_app

# Build and deploy the application using Skaffold
skaffold run -p dev
```

This will deploy a FastAPI application that:
- Uses CloudNative PG for database storage
- Is protected by Istio mesh
- Uses Redis for rate limiting
- Has OpenTelemetry instrumentation for observability

## Part 5: Testing the Application

Let's test the application to verify it's working with the infrastructure.

### Access the Application

```bash
# Port-forward the Istio ingress gateway
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80 &

# In a separate terminal, curl the API
curl http://localhost:8080/api/v1/items
```

You should see a JSON response with sample items from the database.

### Test Authentication

The application has JWT authentication enabled. Let's get a token and test protected endpoints:

```bash
# Get a JWT token
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}' \
  http://localhost:8080/api/v1/auth/token | jq -r .access_token)

# Access a protected endpoint
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v1/users/me
```

### Test Rate Limiting

We can verify that rate limiting is working by making multiple requests:

```bash
# Make 20 rapid requests to trigger rate limiting
for i in {1..20}; do 
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/api/v1/items
  sleep 0.1
done
```

After several requests, you should see `429 Too Many Requests` responses, indicating that rate limiting is working.

### Verify Database Connectivity

Let's verify that the application is correctly connected to the PostgreSQL database:

```bash
# Create a new item
curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title": "Test Item", "description": "Created during testing"}' \
  http://localhost:8080/api/v1/items

# Get all items to verify persistence
curl http://localhost:8080/api/v1/items
```

### Check Observability

Access the OpenTelemetry metrics to see application telemetry:

```bash
# Port-forward the OpenTelemetry collector 
kubectl port-forward -n opentelemetry svc/opentelemetry-collector 8889:8889 &

# Access metrics
curl http://localhost:8889/metrics | grep fastapi
```

## Part 6: Understanding the Integration Points

Let's explore how the application integrates with infrastructure components:

### Istio Integration

The application is configured to work with Istio through:

1. **Sidecar Injection**: The namespace has `istio-injection=enabled` label
2. **Gateway & VirtualService**: Defined in `k8s/istio.yaml` to expose the API
3. **Rate Limiting**: Configured via EnvoyFilters that connect to Redis

### CloudNative PG Integration

The application connects to PostgreSQL via:

1. **Environment Variables**: Using `DATABASE_URL` coming from a Kubernetes Secret
2. **Secret Creation**: External Secrets Operator creates a Secret from PostgreSQL credentials
3. **Alembic Migrations**: Run automatically at startup to set up database schema

### Redis Integration

Redis is used for:

1. **Rate Limiting**: Through Istio EnvoyFilters
2. **Caching**: Application caches certain responses using Redis

### Cert Manager Integration

TLS certificates are managed by:

1. **Self-Signed Issuer**: For local development HTTPS
2. **Certificate Resource**: Defined in `k8s/tls.yaml`

## Part 7: Cleaning Up

When you're done with the tutorial, clean up the resources:

```bash
# Clean up the application
cd ../projects/template/template_fastapi_app
skaffold delete

# Clean up infrastructure 
cd ../../terraform_dev_local  # or pulumi_dev_local
terraform destroy -auto-approve  # or pulumi destroy -y

# Stop Colima
colima stop
```

## Troubleshooting

If you encounter issues during the tutorial, check these common problems:

### Application Unable to Connect to Database

1. Verify the PostgreSQL cluster is running:
   ```bash
   kubectl get clusters.postgresql -n cnpg-cluster
   ```

2. Check if the database secret exists:
   ```bash
   kubectl get secret app-db-credentials -n default
   ```

3. Look at application logs:
   ```bash
   kubectl logs -l app=fastapi-app
   ```

### Istio Gateway Not Working

1. Check if the gateway is correctly configured:
   ```bash
   kubectl get gateway,virtualservice
   ```

2. Verify Istio ingress pods are running:
   ```bash
   kubectl get pods -n istio-system -l app=istio-ingressgateway
   ```

### Rate Limiting Not Working

1. Check if Redis is running:
   ```bash
   kubectl get pods -n redis
   ```

2. Verify EnvoyFilters are correctly applied:
   ```bash
   kubectl get envoyfilters -n istio-system
   ```

## Next Steps

After completing this tutorial, you can:

1. **Explore Advanced Features**: Try enabling other components like ArgoCD or MongoDB
2. **Modify the Application**: Extend the FastAPI app with new features
3. **Deploy Custom Components**: Add your own infrastructure components 
4. **Configure Production Settings**: Adjust resource limits, high availability settings, etc.

For more detailed information, refer to the component-specific documentation in the repository. 