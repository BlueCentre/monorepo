# Template FastAPI Application

A production-ready FastAPI application template showcasing best practices for building web services.

## Features

- **FastAPI Framework**: High-performance, easy to learn, fast to code, ready for production
- **PostgreSQL Integration**: Full ORM support with SQLAlchemy
- **Authentication**: JWT token-based auth with OAuth2
- **Fully Typed**: Leveraging Python type hints throughout
- **OpenAPI Documentation**: Automatic interactive API documentation
- **Containerized**: Docker setup for easy deployment
- **Testing**: Comprehensive test suite with pytest
- **Dependency Management**: Clean dependency handling
- **Async Support**: Asynchronous endpoint handling
- **Logging & Telemetry**: Built-in observability with OpenTelemetry
- **Robust Database Connectivity**: Handles complex Kubernetes environments with automatic connection string parsing

## Monorepo Integration

This application is fully integrated with the monorepo build system. You can run:

```bash
bazel build //... && bazel test //... && skaffold run -m template-fastapi-app -p dev
```

This command works without any workarounds because:

- Proper Java version configuration is set in `.bazelrc`
- The tests handle dependency differences gracefully
- Pydantic version compatibility is handled automatically
- Robust database connection handling for Kubernetes environments
- OpenTelemetry tests use mocks to avoid external dependencies

## Development

### Local Development

```bash
# Clone the repository
git clone <repo-url>
cd template-fastapi-app

# Set up a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the application in development mode
uvicorn app.main:app --reload
```

### Containerized Development

Using Docker Compose:

```bash
docker-compose up -d
```

Using Skaffold for Kubernetes:

```bash
skaffold dev
```

## Testing

### Running Tests

The application includes multiple test suites:

```bash
# Run all tests
pytest

# Run specific test modules
pytest tests/test_main.py

# Run with monorepo integration
bazel test //projects/template/template_fastapi_app:all_tests
```

### Testing Configurations

The monorepo includes several testing configurations:

- `bazel test //... --config=progressive` - Runs independent tests 
- `bazel test //... --config=dev` - Fast testing configuration
- `bazel test //... --config=ci` - CI-optimized testing

## API Documentation

When running the application, access the interactive API documentation at:

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Project Structure

```
├── app/                    # Application code
│   ├── api/                # API endpoints
│   ├── core/               # Core functionality
│   ├── db/                 # Database models and utils
│   ├── schemas/            # Pydantic models
│   └── services/           # Business logic
├── tests/                  # Test modules
├── requirements.txt        # Dependencies
├── run.py                  # Entry point
└── BUILD.bazel             # Bazel build configuration
```

## Additional Documentation

For more detailed information, see:

- [Monorepo Integration Guide](docs/monorepo-integration.md)
- [Deployment Guide](docs/deployment.md)
- [API Documentation](docs/api.md)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Environment Variables

The application is configured using the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_SERVER` | PostgreSQL host | `localhost` |
| `POSTGRES_PORT` | PostgreSQL port | `5432` |
| `POSTGRES_USER` | PostgreSQL username | `postgres` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `postgres` |
| `POSTGRES_DB` | PostgreSQL database name | `app` |
| `SECRET_KEY` | Secret key for JWT tokens | Auto-generated |
| `ENVIRONMENT` | Environment name (development, production) | `development` |
| `ENABLE_TELEMETRY` | Enable OpenTelemetry | `True` |

### Kubernetes Environment Handling

In Kubernetes environments, the application automatically handles environment variables that might be in a different format:

- `POSTGRES_PORT` might come as `tcp://10.43.82.247:5432` - the application extracts the port number properly
- `POSTGRES_SERVER` might include TCP protocol - this is handled automatically
- If the database connection fails, it falls back to an in-memory SQLite database for testing purposes

## Verification

The application includes verification steps that can be used to ensure the deployment is working correctly:

```bash
# Run the complete verification process
skaffold verify -m template-fastapi-app -p dev

# Run only database verification 
skaffold verify -m template-fastapi-app -p db-verify-only

# Run only API verification
skaffold verify -m template-fastapi-app -p api-verify-only

# Skip verification during deployment
skaffold run -m template-fastapi-app -p dev,skip-verify
```

The verification steps include:

1. **Database Verification**: Checks that the database is initialized with the default superuser and sample data
2. **API Verification**: Tests the health endpoint, login endpoint, and users endpoint

These verification steps connect directly to the Kubernetes services using their in-cluster DNS names, ensuring that they work correctly within the Kubernetes environment. No local scripts or port forwarding is required.
