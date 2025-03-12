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
- **Secret Rotation**: Automatic and manual rotation of JWT keys and database credentials for enhanced security
- **API Rate Limiting**: Infrastructure-level protection against abuse using Istio service mesh

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

# Build and test everything in the application
skaffold build && skaffold test && skaffold run && skaffold verify

# Deploy the application (with Istio)
skaffold run <to-fill-in-later>

# Verify the deployment
skaffold verify -m template-fastapi-app -p dev
```

The verification steps are designed to work seamlessly in the monorepo context, automatically adapting to the Kubernetes environment created by Skaffold. This ensures consistent verification across all environments, from local development to CI/CD pipelines.

## Development

### Local Containerized Development

Using Skaffold for Kubernetes:

```bash
skaffold dev
```

Using Skaffold for Kubernetes with multiple applications:

```bash
skaffold dev -m template-fastapi-app
```

Using Skaffold for Kubernetes with multiple applications and profiles:

```bash
skaffold dev -m template-fastapi-app -p dev
```

### Development Workflow with Verification

Integrating verification into your development workflow helps ensure that your application is fully functional after deployment. Here's how to incorporate verification:

1. **Development-Test-Verify Cycle**:
   ```bash
   # Build, test, deploy, and verify
   skaffold build -m template-fastapi-app -p dev && \
   skaffold test -m template-fastapi-app -p dev && \
   skaffold run -m template-fastapi-app -p dev && \
   skaffold verify -m template-fastapi-app -p dev
   ```

2. **Interactive Development with Verification**:
   ```bash
   # Start development mode
   skaffold dev -m template-fastapi-app -p dev
   
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
| `SECRET_ROTATION_ENABLED` | Enable automatic secret rotation | `True` |
| `SECRET_KEY_LIFETIME_DAYS` | Number of days before a secret key expires | `30` |
| `SECRET_KEY_TRANSITION_DAYS` | Number of days for transition period before expiration | `1` |

### Kubernetes Environment Handling

In Kubernetes environments, the application automatically handles environment variables that might be in a different format:

- `POSTGRES_PORT` might come as `tcp://10.43.82.247:5432` - the application extracts the port number properly
- `POSTGRES_SERVER` might include TCP protocol - this is handled automatically
- If the database connection fails, it falls back to an in-memory SQLite database for testing purposes

## Secret Rotation

The application includes a sophisticated secret rotation mechanism that enhances security by automatically rotating sensitive credentials, including JWT signing keys and database credentials. This ensures that even if credentials are compromised, they have a limited lifetime, reducing the risk of unauthorized access.

### Key Concepts

- **Key Rotation**: The process of periodically replacing cryptographic keys to limit their exposure
- **Transition Period**: Time window during which both old and new keys are valid to ensure smooth transitions
- **Secret Lifecycle**: Creation, active use, transition, and expiration phases of secrets

### How Secret Rotation Works

The secret rotation mechanism works as follows:

1. **Initialization**:
   - On application startup, the `SecretRotationManager` loads or initializes secret keys
   - If no keys exist, it generates new keys using the values from environment variables
   - Keys are stored in a secure JSON file with their creation and expiration timestamps

2. **Automatic Rotation**:
   - Keys are automatically checked for expiration on application startup and during operations
   - When a key approaches its expiration date (determined by `SECRET_KEY_TRANSITION_DAYS`), a new key is generated
   - During the transition period, both the old and new keys are valid
   - After the transition period, the old key is no longer used for new operations but remains valid for verification

3. **JWT Key Rotation**:
   - JWT signing keys are rotated based on the configured lifetime
   - During the transition period, the application can verify tokens signed with either the old or new key
   - New tokens are always signed with the current key

4. **Database Credential Rotation**:
   - Database credentials can also be rotated automatically
   - The application will use the most recent credentials for database connections
   - Note: External database users must be updated separately

### Configuration

The secret rotation mechanism can be configured with the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRET_ROTATION_ENABLED` | Enable or disable automatic secret rotation | `True` |
| `SECRET_KEY_LIFETIME_DAYS` | Number of days a secret key is valid | `30` |
| `SECRET_KEY_TRANSITION_DAYS` | Number of days for transition period before expiration | `1` |

### API Endpoints for Key Management

The application provides secure endpoints for managing keys. These endpoints are only accessible to superusers:

- **GET `/api/v1/key-management/status`**: Get the status of all JWT keys and DB credentials
- **POST `/api/v1/key-management/rotate-jwt-key`**: Force immediate rotation of the JWT signing key
- **POST `/api/v1/key-management/rotate-db-credentials`**: Force immediate rotation of the DB credentials

### Example: Manually Rotating Keys

In some scenarios, you might want to manually trigger key rotation:

```bash
# Get the current status of keys
curl -X GET \
  http://localhost:8000/api/v1/key-management/status \
  -H 'Authorization: Bearer YOUR_ADMIN_TOKEN'

# Force rotation of JWT key
curl -X POST \
  http://localhost:8000/api/v1/key-management/rotate-jwt-key \
  -H 'Authorization: Bearer YOUR_ADMIN_TOKEN'

# Force rotation of database credentials
curl -X POST \
  http://localhost:8000/api/v1/key-management/rotate-db-credentials \
  -H 'Authorization: Bearer YOUR_ADMIN_TOKEN'
```

### Best Practices for Secret Rotation

1. **Monitoring**: Regularly check the status of your keys through the API endpoints
2. **Testing**: After rotation, verify that your application still works properly
3. **Emergency Rotation**: If you suspect a key has been compromised, rotate it immediately
4. **Database Synchronization**: When rotating database credentials, ensure the database is updated accordingly
5. **Backup**: Always maintain backups of your secret files in secure locations

### Implementation Details

The secret rotation mechanism is implemented in the `app/core/secret_rotation.py` file. The main components are:

- `SecretRotationManager`: Core class that handles all aspects of secret rotation
- `JWT_KEY_TYPE` and `DB_CREDENTIAL_TYPE`: Constants defining the types of secrets managed
- Integration with `app/core/security.py` for JWT token operations

For automated testing of the secret rotation mechanism, see the test files:
- `tests/test_secret_rotation.py`: Tests for the core rotation mechanism
- `tests/test_key_management_api.py`: Tests for the API endpoints

## API Rate Limiting

This application includes API rate limiting capabilities using Istio service mesh. The rate limiting feature allows you to:

1. Protect your API endpoints from abuse
2. Implement different rate limits for different endpoints
3. Configure rate limits based on client identity
4. Monitor and track rate limiting metrics

### Development Workflow

Developers can work with this application in two modes:

#### Standard Mode (Without Istio)

For regular development without rate limiting:

```bash
# Deploy the application without Istio rate limiting
skaffold run -m template-fastapi-app -p dev

# For development with live reload
skaffold dev -m template-fastapi-app -p dev
```

This will:
- Deploy the application with standard Kubernetes resources
- Set up the database and run migrations
- Configure basic networking without rate limiting
- Deploy verification jobs to ensure everything is working

#### Rate Limiting Mode (With Istio)

For development with Istio rate limiting enabled:

```bash
# Step 1: Deploy Istio system resources
skaffold run -m istio-system-resources

# Step 2: Deploy the application with Istio rate limiting
skaffold run -m template-fastapi-app -p istio-rate-limit

# Step 3: Verify rate limiting functionality
skaffold verify -m template-fastapi-app -p istio-rate-limit
```

This will:
- Deploy the application with standard Kubernetes resources
- Enable Istio injection on the namespace using a Kubernetes job
- Deploy Istio rate limiting configurations
- Set up the rate limiting service and Redis backend
- Configure the virtual service with rate limiting rules

### Verifying Rate Limiting

To verify that rate limiting is working correctly:

```bash
# Verify using Skaffold's built-in verification
skaffold verify -m template-fastapi-app -p istio-rate-limit

# Or manually test rate limiting:
# Port forward to the application
kubectl port-forward -n template-fastapi-app svc/template-fastapi-app 8000:80

# Make multiple rapid requests to trigger rate limiting
for i in {1..20}; do curl -i localhost:8000/api/v1/items/; sleep 0.1; done
```

With rate limiting enabled, you should see HTTP 429 (Too Many Requests) responses after the configured number of requests.

### Rate Limiting Configuration

The rate limits are configured in the following files:

- `kubernetes/istio/rate-limiting.yaml`: Main rate limiting configuration
- `kubernetes/istio/virtual-service.yaml`: Routing rules with rate limiting metadata
- `kubernetes/istio/rate-limit-handler.yaml`: Rate limit handler configuration

You can modify these files to adjust the rate limits for different endpoints.

### Switching Between Modes

To switch from rate-limited mode back to standard mode:

```bash
# Disable Istio rate limiting and redeploy the application
skaffold run -m template-fastapi-app -p disable-istio
```

This will:
- Disable Istio injection on the namespace using a Kubernetes job
- Deploy the application without Istio resources

### Troubleshooting

Common issues with rate limiting:

1. **Rate limiting not working**: Ensure Istio is properly installed and the namespace has Istio injection enabled
2. **429 errors when not expected**: Check the rate limit configuration in `kubernetes/istio/rate-limiting.yaml`
3. **Istio resources not deploying**: Verify that Istio is installed in your cluster

For more detailed troubleshooting information, see the [ISTIO-TROUBLESHOOTING.md](./ISTIO-TROUBLESHOOTING.md) file which documents known issues and their resolutions.

For more detailed information, see the [ISTIO-SETUP.md](./ISTIO-SETUP.md) file.

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

## Deployment and Validation Guide

This guide provides a step-by-step approach to building, testing, deploying, and validating the FastAPI application and its dependencies.

> **🔑 Key Principle**: All validations are performed using container-based approaches for consistency between local development and CI/CD pipelines.

### Step 1: Set Up Your Environment

```bash
# Navigate to your monorepo
cd /path/to/monorepo

# Ensure your Kubernetes context is set correctly
kubectl config current-context
```

### Step 2: Build and Deploy for Development

#### Standard Deployment (Default Approach)

```bash
# Create namespace if it doesn't exist
kubectl create namespace template-fastapi-app

# Build and deploy using the no-istio profile
skaffold run -m template-fastapi-app -p no-istio
```

This default approach:
- Works in all Kubernetes environments regardless of whether Istio is installed
- Uses a streamlined deployment that includes only the application components
- Deploys the FastAPI application, PostgreSQL database, and necessary configurations
- Includes standard health checks and readiness probes

#### Development Mode with Live Reload

```bash
# Start development mode with live reload
skaffold dev -m template-fastapi-app -p no-istio
```

This command:
- Builds and deploys the application
- Watches for file changes and automatically rebuilds/redeploys
- Provides a development-friendly workflow for iterative changes

#### Optional: Deployment with Rate Limiting (Requires Istio)

For environments where Istio is installed and rate limiting is needed:

```bash
# First, verify that Istio is installed
kubectl get namespace istio-system

# If Istio is installed, deploy with rate limiting enabled
skaffold run -m template-fastapi-app -p istio-rate-limit-actions
```

### Step 3: Run Post-Deployment Validation

```bash
# Run the standard verification suite
skaffold verify -m template-fastapi-app -p dev
```

This will run container-based verification tests to ensure:
- The application is healthy and responding
- Authentication is working correctly
- API endpoints are accessible and returning expected data
- Key management functionality is operational

### Step 4: Complete CI/CD Pipeline Commands

For CI/CD environments, you can chain the commands:

```bash
# Complete build-deploy-verify pipeline
skaffold build -m template-fastapi-app -p no-istio && \
skaffold deploy -m template-fastapi-app -p no-istio && \
skaffold verify -m template-fastapi-app -p dev
```

### Step 5: Cleaning Up Resources

```bash
# Delete all deployed resources
skaffold delete -m template-fastapi-app
```

### Common Workflow Scenarios

#### Local Development Loop

```bash
# Create namespace if needed
kubectl create namespace template-fastapi-app

# Start development mode with live reload
skaffold dev -m template-fastapi-app -p no-istio
```

#### Feature Branch Testing

```bash
# Complete build-test-deploy-verify cycle for a feature branch
skaffold build -m template-fastapi-app -p no-istio && \
skaffold deploy -m template-fastapi-app -p no-istio && \
skaffold verify -m template-fastapi-app -p dev
```

#### Production Deployment

```bash
# Deploy to production (using an appropriate profile)
skaffold run -m template-fastapi-app -p no-istio && \
skaffold verify -m template-fastapi-app -p dev
```

### Verification Process

After deployment, validation should be performed using container-based approaches to maintain consistency with CI/CD pipelines:

#### Using Skaffold Verify

The recommended way to validate deployments is through Skaffold's built-in verification mechanism:

```bash
# Run the complete verification process
skaffold verify -m template-fastapi-app -p dev
```

These verification steps run in containers within the Kubernetes cluster and perform comprehensive checks:

1. **Health Check Verification**: Confirms the application is responding
2. **Authentication Verification**: Tests login functionality
3. **API Functionality Verification**: Checks that endpoints return expected data
4. **Database Verification**: Confirms database connectivity and initialization

### Troubleshooting Guide

If you encounter issues during any step, here are common problems and solutions:

#### Build and Test Issues

1. **Bazel build fails with dependency errors**
   - Ensure you have the correct Java version specified in .bazelrc
   - Run `bazel clean --expunge` and try again
   - Check for any version conflicts in dependencies

2. **Tests fail**
   - Check the test logs: `bazel test //projects/template/template_fastapi_app:all_tests --test_output=all`
   - Verify environment setup matches test expectations
   - Look for specific test failures and address each one

#### Deployment Issues

1. **Namespace already exists or not found**
   - If namespace exists: Continue with deployment
   - If namespace not found: `kubectl create namespace template-fastapi-app`

2. **Skaffold deployment fails**
   - Check for proper Docker and Kubernetes configurations
   - Ensure Skaffold is properly installed
   - Verify the image can be built: `skaffold build -m template-fastapi-app`

3. **Pods are not starting or are crashing**
   - Check pod logs: `kubectl logs -n template-fastapi-app deploy/template-fastapi-app`
   - Check pod events: `kubectl describe pod -n template-fastapi-app <pod-name>`
   - Check for resource constraints: `kubectl get pod -n template-fastapi-app <pod-name> -o yaml`

4. **Database connectivity issues**
   - Check if Postgres is running: `kubectl get pods -n template-fastapi-app -l app=postgres`
   - Verify database connection settings in the configmap: `kubectl get configmap -n template-fastapi-app`

5. **Istio-related deployment failures**
   - If using `istio-rate-limit-actions` profile when Istio is not installed:
     - Switch to `no-istio` profile: `skaffold run -m template-fastapi-app -p no-istio`
   - If Istio is needed: Install it with `istioctl install --set profile=demo`

#### Verification Issues

1. **Verification fails at health check**
   - Check if the application is running: `kubectl get pods -n template-fastapi-app`
   - Check application logs: `kubectl logs -n template-fastapi-app deploy/template-fastapi-app`
   - Verify service exists: `kubectl get svc -n template-fastapi-app`

2. **Authentication verification fails**
   - Check database initialization: `kubectl logs -n template-fastapi-app -l app=postgres`
   - Verify default credentials are set correctly
   - Check application logs for JWT errors: `kubectl logs -n template-fastapi-app deploy/template-fastapi-app`

3. **Database verification fails**
   - Verify database initialization: `kubectl logs -n template-fastapi-app job/db-init`
   - Check for database connection errors in application logs
   - Ensure PostgreSQL is running properly: `kubectl exec -n template-fastapi-app deploy/postgres -- pg_isready`

## Admin User

The application automatically creates an admin user during initialization with the following credentials:

- Email: `admin@example.com`
- Password: `admin`

The admin user is created by the database migration job (`db-migrations-job.yaml`). The job follows a two-step approach:

1. First, it attempts to run Alembic migrations if the configuration files are present
2. If Alembic is not available or fails, it falls back to:
   - Creating database tables using SQLAlchemy's `Base.metadata.create_all()`
   - Creating the admin user using direct SQL commands

This hybrid approach ensures that the database is properly initialized regardless of the environment, while still preferring Alembic migrations when available.

### Database Migrations

For schema changes, we recommend using Alembic migrations:

1. Define database models in SQLAlchemy classes within the application code
2. Create a new Alembic migration if you need to change the schema or add data:
   ```bash
   alembic revision -m "your_migration_description"
   ```
3. Edit the generated migration file to implement your changes
4. The migrations will be applied automatically during deployment

### Password Hashing

The application uses bcrypt for password hashing. If you need to update the admin password, you can generate a new hash using:

```python
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
new_hash = pwd_context.hash('your_new_password')
print(new_hash)
```

Then update the password in the `db-migrations-job.yaml` file.

### Authentication

The application uses JWT tokens for authentication. You can obtain a token by sending a POST request to the `/api/v1/login/access-token` endpoint:

```bash
curl -X POST "http://localhost:8000/api/v1/login/access-token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin@example.com&password=admin"
```

The response will include an access token that can be used to authenticate subsequent requests:

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

Use this token in the Authorization header for authenticated requests:

```bash
curl -X GET "http://localhost:8000/api/v1/users/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Rate Limiting

This application includes rate-limited endpoints that demonstrate how to protect APIs from abuse using token authentication and rate limiting.

### Rate Limited Endpoints

The application provides two examples of rate-limited endpoints:

1. **IP-based Rate Limiting**: `/api/v1/rate-limited/rate-limited`
   - Limited to 5 requests per minute per IP address
   - Requires token authentication
   - Returns user information on successful access

2. **User-based Rate Limiting**: `/api/v1/rate-limited/rate-limited-user`
   - Limited to 10 requests per minute per user ID
   - Requires token authentication
   - Demonstrates custom key function for per-user rate limiting
   - Returns user information on successful access

### Implementation Details

The rate limiting is implemented using the `slowapi` package which provides:

- Global rate limiting configuration in `main.py`
- Per-endpoint rate limiting with custom key functions
- Automatic integration with FastAPI's exception handling system
- Customizable rate limit error responses

To use the rate-limited endpoints:

1. First authenticate via `/api/v1/login/access-token` to get a token
2. Include the token in the Authorization header for subsequent requests
3. When rate limits are exceeded, the API returns a 429 Too Many Requests response

Example usage:

```bash
# Get auth token
curl -X POST "http://localhost:8000/api/v1/login/access-token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin@example.com&password=password"

# Access rate-limited endpoint with token
curl -X GET "http://localhost:8000/api/v1/rate-limited/rate-limited" \
  -H "Authorization: Bearer YOUR_TOKEN"
```