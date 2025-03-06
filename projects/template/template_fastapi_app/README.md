# Template FastAPI App

A template FastAPI application with PostgreSQL, PubSub, and more.

## Features

- **FastAPI** framework for building APIs
- **PostgreSQL** database with SQLAlchemy ORM
- **Alembic** for database migrations
- **JWT** authentication
- **Google Cloud PubSub** integration
- **OpenTelemetry** for observability and tracing
- **Kubernetes** deployment with Skaffold
- **Bazel** build system integration

## Development

### Prerequisites

- Python 3.11+
- Docker
- Kubernetes (local or remote)
- Bazel

### Setup

1. Clone the repository
2. Install dependencies:

```bash
pip install -r requirements.txt
```

### Running with Bazel

This application is integrated with Bazel for building and packaging:

```bash
# Build the application binary
bazel build //projects/template/template_fastapi_app:run_bin

# Build the container image
bazel build //projects/template/template_fastapi_app:image_tarball

# Load the image into Docker
docker load < bazel-bin/projects/template/template_fastapi_app/image_tarball.tar
```

Alternatively, you can use the helper script:

```bash
cd projects/template/template_fastapi_app
./skaffold.sh build
```

### Running with Skaffold

This application uses Skaffold for development and deployment:

```bash
# Run in development mode
./skaffold.sh dev

# Run in production mode
./skaffold.sh run

# Delete the deployment
./skaffold.sh delete
```

### Accessing the Application

After deployment, you can access the application at:

- API: http://localhost:8000/api/v1
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### OpenTelemetry Integration

The application is integrated with OpenTelemetry for distributed tracing and metrics:

```bash
# Port forward the OpenTelemetry collector
kubectl port-forward service/otel-collector -n template-fastapi-app 4317:4317 16686:16686 &
```

The OpenTelemetry collector exposes the following endpoints:

- OTLP gRPC endpoint: http://localhost:4317
- OTLP HTTP endpoint: http://localhost:4318
- Prometheus metrics: http://localhost:8889

## Project Structure

```
.
├── app                     # Application code
│   ├── api                 # API endpoints
│   ├── core                # Core functionality
│   ├── crud                # CRUD operations
│   ├── db                  # Database models and session
│   ├── models              # SQLAlchemy models
│   ├── schemas             # Pydantic schemas
│   └── services            # Business logic
├── kubernetes              # Kubernetes manifests
├── tests                   # Tests
├── alembic                 # Database migrations
├── alembic.ini             # Alembic configuration
├── BUILD.bazel             # Bazel build configuration
├── Dockerfile.bazel        # Dockerfile for Bazel builds
├── requirements.txt        # Python dependencies
├── run.py                  # Application entry point
└── skaffold.yaml           # Skaffold configuration
```

## Troubleshooting

### Common Issues

#### Python Path Issues

If you encounter import errors related to Python's built-in modules, check the `PYTHONPATH` environment variable in the Dockerfile. The application code should be in a separate directory to avoid conflicts with Python's built-in modules.

#### Database Connection Issues

If you encounter database connection issues, check the database configuration in `app/core/config.py`. The application is configured to use PostgreSQL, and the connection string is built from environment variables.

#### Kubernetes Deployment Issues

If you encounter issues with the Kubernetes deployment, check the Kubernetes manifests in the `kubernetes` directory. The application is configured to use Skaffold for deployment, and the Skaffold configuration is in `skaffold.yaml`.

#### OpenTelemetry Issues

The OpenTelemetry collector configuration is in `kubernetes/otel-collector.yaml`. If you encounter issues with the OpenTelemetry collector, check the following:

- Make sure the `debug` exporter is used instead of the deprecated `logging` exporter
- Verify that the collector is running with `kubectl get pods -n template-fastapi-app`
- Check the collector logs with `kubectl logs -n template-fastapi-app <otel-collector-pod-name>`

## License

MIT
