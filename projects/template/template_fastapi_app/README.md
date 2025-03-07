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

### Full Integration Workflow

For a complete development and deployment flow within the monorepo:

```bash
# Build and test everything in the monorepo
bazel build //... && bazel test //...

# Deploy the application
skaffold run -m template-fastapi-app -p dev

# Verify the deployment
skaffold verify -m template-fastapi-app -p dev
```

The verification steps are designed to work seamlessly in the monorepo context, automatically adapting to the Kubernetes environment created by Skaffold. This ensures consistent verification across all environments, from local development to CI/CD pipelines.

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

### Development Workflow with Verification

Integrating verification into your development workflow helps ensure that your application is fully functional after deployment. Here's how to incorporate verification:

1. **Development-Test-Verify Cycle**:
   ```bash
   # Build, test, deploy, and verify
   bazel build //projects/template/template_fastapi_app:image_tarball && \
   bazel test //projects/template/template_fastapi_app:all_tests && \
   skaffold run -m template-fastapi-app -p dev && \
   skaffold verify -m template-fastapi-app -p dev
   ```

2. **Interactive Development with Verification**:
   ```bash
   # Start development mode
   skaffold dev -m template-fastapi-app
   
   # In another terminal, run verification after making changes
   skaffold verify -m template-fastapi-app -p dev
   ```

3. **Targeted Verification During Development**:
   - After changing database schema: `skaffold verify -m template-fastapi-app -p db-verify-only`
   - After modifying API endpoints: `skaffold verify -m template-fastapi-app -p api-verify-only`

This approach helps catch integration issues early, especially those that might not be apparent from unit tests alone, such as authentication flows, database connectivity, and proper API response formatting.

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

### Smoke Test Implementation

The smoke test is implemented in the `skaffold.yaml` file and uses a robust approach to ensure reliable API verification:

1. It first tries multiple different service addressing methods to find a working endpoint:
   - Direct service name: `http://template-fastapi-app/health`
   - Namespaced service name: `http://template-fastapi-app.template-fastapi-app/health`
   - Fully qualified service names: `http://template-fastapi-app.template-fastapi-app.svc/health`
   - Direct service IP address

2. Once a working endpoint is found, it performs comprehensive verification:
   - **Health check**: Verifies the application is up and running
   - **Authentication**: Tests the login flow with default credentials
   - **API functionality**: Verifies that API endpoints return expected data

### Customizing Verification

Developers can customize the verification process for their own applications:

1. **Adding new endpoints to verify**: Edit the `skaffold.yaml` file's `verify` section to include additional API endpoints that are important for your application.

2. **Creating custom verification profiles**: Add new profiles to the `skaffold.yaml` file following the pattern of existing profiles like `db-verify-only`.

3. **Adjusting verification timing**: Modify the sleep durations and retry counts in the verification scripts to match your application's startup characteristics.

4. **Extending for microservices**: For microservice architectures, create similar verification steps for each service and combine them in a meta-module.

### Troubleshooting Verification

If verification fails, you can debug by:

1. Checking the logs of the verification container: `kubectl logs -n your-namespace verification-pod-name`
2. Ensuring your services are properly deployed: `kubectl get svc -n your-namespace`
3. Validating service accessibility from within the cluster: `kubectl exec -it your-app-pod -- curl http://your-service/health`

The robust service discovery mechanism in the verification script will automatically try multiple addressing approaches, making it resilient to various Kubernetes network configurations.

## Code Quality and Maintainability

This project uses several tools to ensure code quality and maintainability:

### Type Checking

We use MyPy for static type checking with strict settings:

```bash
# Run type checking
mypy app
```

### Linting and Formatting

We use a combination of tools for linting and formatting:

- **Ruff**: Fast Python linter that combines multiple linting tools
- **Black**: Code formatter with consistent style
- **isort**: Import sorter that works with Black

```bash
# Run all linting checks
ruff check app tests
black --check app tests
isort --check app tests

# Auto-format code
ruff check --fix app tests
black app tests
isort app tests
```

### Pre-commit Hooks

We use pre-commit hooks to ensure code quality before committing:

```bash
# Install pre-commit hooks
pre-commit install

# Run pre-commit hooks manually
pre-commit run --all-files
```

### Security Scanning

We scan dependencies and code for security vulnerabilities:

```bash
# Scan dependencies for security vulnerabilities
./scripts/scan_dependencies.sh

# Run security checks during pre-commit
pre-commit run gitleaks --all-files
```

### Complexity Analysis

We analyze code complexity to maintain maintainable code:

```bash
# Run complexity analysis
./scripts/analyze_complexity.sh
```

### Code Coverage with SonarQube

We use SonarQube for code coverage and quality analysis:

```bash
# Generate coverage reports for SonarQube
./scripts/run_tests_with_coverage.sh

# Run SonarQube analysis (requires SonarQube server)
sonar-scanner
```
