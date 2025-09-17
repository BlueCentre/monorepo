# Template FastAPI Application - Developer Quickstart

This guide helps you set up and start working with the Template FastAPI Application quickly. It covers the essentials to get you up and running in minutes.

## Prerequisites

You'll need the following tools installed on your local machine:

- **Docker** (with Docker Compose)
- **Colima** (macOS) or Docker Desktop for local Kubernetes
- **kubectl** - Kubernetes command-line tool
- **Helm** - Kubernetes package manager
- **Skaffold** - Application deployment workflow tool
- **Python 3.10+** - For running scripts/tools locally
- **Git** - For version control
- Either **Terraform** or **Pulumi** for infrastructure setup (described below)

## Setup in 5 Minutes

Follow these steps to get the application running:

### 1. Start local Kubernetes cluster

Start Colima with sufficient resources for the infrastructure components:

```bash
# Start Colima with 4 CPUs, 8GB RAM 
colima start --cpu 4 --memory 8
```

### 2. Deploy infrastructure components

You have two options to deploy the required infrastructure:

#### Option 1: Using Terraform

```bash
# Navigate to the Terraform directory
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Deploy infrastructure
terraform apply -auto-approve
```

#### Option 2: Using Pulumi

```bash
# Navigate to the Pulumi directory
cd infrastructure/pulumi

# Initialize Pulumi
pulumi stack init dev

# Deploy infrastructure
pulumi up -y
```

### 3. Run the application in development mode

```bash
# Navigate to the application directory
cd ../../

# Start the application in dev mode
skaffold dev --port-forward
```

This will build the Docker image, deploy the application to your local Kubernetes cluster, and set up port forwarding so you can access the application.

## Key URLs

After the application is running, you can access:

- **API Documentation**: http://localhost:8000/api/docs
- **Alternative API Documentation**: http://localhost:8000/api/redoc
- **Health Check**: http://localhost:8000/api/health
- **Metrics**: http://localhost:8000/api/metrics

## Common Development Tasks

### Authentication

1. **Create a user**:
   ```bash
   curl -X POST "http://localhost:8000/api/users/" \
     -H "Content-Type: application/json" \
     -d '{"email":"user@example.com","password":"password123","full_name":"Test User"}'
   ```

2. **Get an authentication token**:
   ```bash
   curl -X POST "http://localhost:8000/api/auth/token" \
     -H "Content-Type: application/json" \
     -d '{"username":"user@example.com","password":"password123"}'
   ```

3. **Use the token to access protected endpoints**:
   ```bash
   curl -X GET "http://localhost:8000/api/users/me" \
     -H "Authorization: Bearer YOUR_TOKEN_HERE"
   ```

### Creating new items

```bash
curl -X POST "http://localhost:8000/api/items/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"title":"New Item","description":"Item description"}'
```

### Running Tests

```bash
# Run unit tests
pytest tests/unit

# Run integration tests
pytest tests/integration

# Run API tests
pytest tests/api

# Run all tests
pytest
```

## Project Structure Overview

```
├── app/                  # Main application code
│   ├── api/              # API routes and endpoints
│   │   ├── deps.py       # API dependencies
│   │   └── routes/       # Route definitions
│   ├── core/             # Core application code
│   │   ├── config.py     # Configuration management
│   │   └── security.py   # Security utilities
│   ├── db/               # Database setup
│   ├── models/           # Database models
│   ├── repositories/     # Data access layer
│   ├── schemas/          # Pydantic models for request/response
│   ├── services/         # Business logic
│   └── main.py           # Application entry point
│
├── tests/                # Test suite
│   ├── unit/             # Unit tests
│   ├── integration/      # Integration tests
│   └── api/              # API tests
│
├── migrations/           # Alembic migrations
│
├── kubernetes/           # Kubernetes manifests
│   ├── templates/        # Kubernetes resource templates
│   └── values.yaml       # Deployment values
│
├── infrastructure/       # Infrastructure setup
│   ├── terraform/        # Terraform modules
│   └── pulumi/           # Pulumi configurations
│
├── docs/                 # Documentation
│
├── Dockerfile            # Docker configuration
├── skaffold.yaml         # Skaffold configuration
└── README.md             # Project overview
```

## Modifying the Application

### Adding a new endpoint

1. Create an endpoint in an existing router or create a new one:

```python
# In app/api/routes/items.py
@router.get("/items/featured", response_model=List[schemas.Item])
def get_featured_items(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Retrieve featured items.
    """
    items = item_service.get_featured_items(db, skip=skip, limit=limit)
    return items
```

2. Create the corresponding service method in `app/services/`

### Adding a new environment variable

1. Add the variable to `app/core/config.py`
2. Update Kubernetes ConfigMap in `kubernetes/templates/configmap.yaml`
3. Update `.env.example` with the new setting

## Debugging

### Accessing logs

```bash
# View application logs
kubectl logs -n app deployment/fastapi-app

# Follow logs (continuous stream)
kubectl logs -n app deployment/fastapi-app -f
```

### Debugging database

```bash
# Port forward to PostgreSQL
kubectl port-forward -n database svc/cloudnative-pg 5432:5432

# Connect with psql (in another terminal)
PGPASSWORD=postgres psql -h localhost -U postgres -d app
```

### Accessing Redis

```bash
# Port forward to Redis
kubectl port-forward -n redis svc/redis-master 6379:6379

# Connect with redis-cli (in another terminal)
redis-cli -h localhost -p 6379
```

## Useful Skaffold Commands

```bash
# Run in development mode with hot reload
skaffold dev --port-forward

# Build and deploy once (no watching)
skaffold run --port-forward

# Delete all deployed resources
skaffold delete

# Run tests
skaffold test
```

## Next Steps

After setting up your development environment, you might want to explore:

- [Design Documentation](design-documentation.md) - Detailed architecture and design
- [Architecture Overview](architecture-overview.md) - High-level overview of the system

## Troubleshooting

### Database Connection Issues

If the application can't connect to the database:

1. Check if the PostgreSQL pod is running:
   ```bash
   kubectl get pods -n database
   ```

2. Check the status of the CloudNativePG cluster:
   ```bash
   kubectl describe cluster -n database cloudnative-pg
   ```

3. Check the application logs for connection errors:
   ```bash
   kubectl logs -n app deployment/fastapi-app
   ```

### Istio Gateway Issues

If you're having trouble accessing the application:

1. Check the status of the Istio gateway:
   ```bash
   kubectl get gateway -n istio-system
   ```

2. Check the virtual service:
   ```bash
   kubectl get virtualservice -n app
   ```

3. Check Istio ingress gateway logs:
   ```bash
   kubectl logs -n istio-system deployment/istio-ingressgateway
   ```

### Skaffold Problems

If Skaffold is having issues:

1. Try resetting Skaffold's cache:
   ```bash
   skaffold clean
   ```

2. Run Skaffold with debug logging:
   ```bash
   skaffold dev -v debug
   ```

3. Check if your Docker daemon is running:
   ```bash
   docker info
   ``` 