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
- **Notes API** for managing user notes
- **Seed Data** utilities for generating test data

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

### Database Initialization

The application automatically initializes the database after deployment using Skaffold's verification feature. This includes:

- Creating all required database tables
- Creating a default superuser (admin@example.com/admin)
- Creating a sample item

```bash
# Run with automatic database initialization (default behavior)
skaffold run

# Skip database initialization if needed
skaffold run -p skip-db-init

# Run database initialization manually
kubectl apply -f kubernetes/db-init-job.yaml
```

When running in development mode (`skaffold dev`), the database will be initialized automatically on the first deployment. If you make schema changes during development, you may need to manually rerun the initialization job.

### Accessing the Application

After deployment, you can access the application at:

- API: http://localhost:8000/api/v1
- ReDoc Documentation: http://localhost:8000/docs (primary documentation)
- Swagger UI: http://localhost:8000/swagger (alternative documentation)

### Testing the API

You can test the API using various tools. First, set up port forwarding to access the application:

```bash
# Set up port forwarding
kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80
```

### API Credentials

When the database is initialized, a default superuser is created with these credentials:
- **Username**: `admin@example.com`
- **Password**: `admin`

#### Getting the Credentials

You can retrieve or verify the default credentials in several ways:

1. **From the Configuration**: 
   ```bash
   # View the default superuser settings
   kubectl get configmap template-fastapi-app-config -n template-fastapi-app -o yaml | grep FIRST_SUPERUSER
   ```

2. **From the Database**:
   ```bash
   # Port-forward to the PostgreSQL service
   kubectl port-forward service/postgres -n template-fastapi-app 5432:5432 &
   
   # Connect using the PostgreSQL password from the secret
   PGPASSWORD=$(kubectl get secret postgres-secret -n template-fastapi-app -o jsonpath='{.data.password}' | base64 --decode) \
   psql -h localhost -U postgres -d app -c 'SELECT email, is_superuser FROM "user";'
   ```

3. **From the API Logs**:
   ```bash
   # Check the database initialization job logs
   kubectl get pods -n template-fastapi-app -l component=db-init -o name | xargs kubectl logs -n template-fastapi-app
   ```

#### Changing the Default Credentials

For security in production environments, you should change the default credentials. You can do this:

1. **Via the API**:
   ```bash
   # Login first to get a token
   TOKEN=$(curl -s -X 'POST' 'http://localhost:8000/api/v1/login/access-token' \
     -H 'Content-Type: application/x-www-form-urlencoded' \
     -d 'username=admin@example.com&password=admin' | jq -r '.access_token')
   
   # Update the password
   curl -X 'PUT' 'http://localhost:8000/api/v1/users/me' \
     -H "Authorization: Bearer $TOKEN" \
     -H 'Content-Type: application/json' \
     -d '{
       "password": "new-secure-password",
       "full_name": "Updated Admin Name"
     }'
   ```

2. **Via Configuration**:
   To change the default superuser created during initialization, modify the `FIRST_SUPERUSER` and `FIRST_SUPERUSER_PASSWORD` values in the configuration.

#### Using curl

Here are some examples of common API operations using curl:

**1. Authentication (Get Access Token)**

```bash
# Login with default superuser credentials
curl -X 'POST' \
  'http://localhost:8000/api/v1/login/access-token' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'username=admin@example.com&password=admin'
```

**2. Get Current User Information**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'GET' \
  'http://localhost:8000/api/v1/users/me' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

**3. List Items**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'GET' \
  'http://localhost:8000/api/v1/items/' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

**4. Create a New Item**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'POST' \
  'http://localhost:8000/api/v1/items/' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "New Item",
    "description": "This is a new item created via API",
    "is_active": true
  }'
```

**5. List Notes**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'GET' \
  'http://localhost:8000/api/v1/notes/' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

**6. Create a New Note**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'POST' \
  'http://localhost:8000/api/v1/notes/' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "New Note",
    "content": "This is a new note created via API"
  }'
```

**7. Generate Seed Data**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
# This will create 5 random items and 5 random notes
curl -X 'POST' \
  'http://localhost:8000/api/v1/seed/?num_items=5&num_notes=5' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

**8. Upload Seed Data File**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
# This will create items and notes from a JSON file
curl -X 'POST' \
  'http://localhost:8000/api/v1/seed/upload' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Content-Type: multipart/form-data' \
  -F 'file=@path/to/your/seed_data.json'
```

Example seed data file format:
```json
{
  "items": [
    {
      "title": "Custom Item 1",
      "description": "Description for Custom Item 1",
      "is_active": true
    }
  ],
  "notes": [
    {
      "title": "Custom Note 1",
      "content": "Content for Custom Note 1"
    }
  ]
}
```

#### API Documentation and Testing

The application provides two interactive API documentation interfaces:

**1. ReDoc (Recommended)**

ReDoc provides a clean, responsive, and easy-to-read documentation interface:

1. Open your browser and navigate to http://localhost:8000/docs
2. The documentation is organized by tags and operations
3. You can see:
   - Request and response schemas
   - Example requests and responses
   - Detailed descriptions of parameters
   - Authentication requirements

ReDoc provides excellent documentation but doesn't include an interactive testing interface. For testing, use curl commands or Swagger UI.

**2. Swagger UI (Alternative)**

Swagger UI provides an interactive interface for exploring and testing the API:

1. Open your browser and navigate to http://localhost:8000/swagger
2. You'll see all available API endpoints organized by category
3. To authenticate:
   - Click the "Authorize" button at the top of the page (the padlock icon)
   - The OAuth2 authentication dialog will appear
   - Enter `admin@example.com` for username and `admin` for password
   - Leave client_id and client_secret fields empty
   - Click "Authorize"
   
   **If you encounter "Auth Error TypeError: Failed to fetch" errors:**
   
   This is a known issue with Swagger UI's OAuth2 form. Since Swagger UI doesn't allow adding custom authorization headers to individual requests, you have these alternatives:

   **Option 1: Use pre-acquired token with the Authorize button**
   1. First, get a token using curl:
      ```bash
      TOKEN=$(curl -s -X 'POST' \
        'http://localhost:8000/api/v1/login/access-token' \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        -d 'username=admin@example.com&password=admin' | jq -r '.access_token')
      echo $TOKEN  # Copy this token
      ```
   
   2. In Swagger UI:
      - Click the "Authorize" button (padlock icon)
      - In the "Value" field, enter: `Bearer YOUR_TOKEN` (replacing YOUR_TOKEN with the copied token)
      - Click "Authorize" and close the dialog

   **Option 3: Use other API tools**
   - Use curl commands as shown in the previous section
   - Try API tools like [Postman](https://www.postman.com/) or [Insomnia](https://insomnia.rest/)

4. Once authorized in Swagger UI, you can test any endpoint by:
   - Expanding the endpoint
   - Clicking "Try it out"
   - Filling in the required parameters
   - Clicking "Execute"

**Troubleshooting API Access Issues:**

If you encounter issues accessing the API:
1. Make sure port forwarding is active (`kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80`)
2. Check that the application pod is running (`kubectl get pods -n template-fastapi-app`)
3. Try using an incognito/private browser window
4. Disable browser extensions that might interfere with API requests
5. If using Chrome, check the developer console for CORS or other errors
6. Try using a different browser

### Testing the API

You can test the API using either curl commands or the interactive Swagger UI. First, set up port forwarding to access the application:

```bash
# Set up port forwarding
kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80
```

### API Credentials

When the database is initialized, a default superuser is created with these credentials:
- **Username**: `admin@example.com`
- **Password**: `admin`

#### Getting the Credentials

You can retrieve or verify the default credentials in several ways:

1. **From the Configuration**: 
   ```bash
   # View the default superuser settings
   kubectl get configmap template-fastapi-app-config -n template-fastapi-app -o yaml | grep FIRST_SUPERUSER
   ```

2. **From the Database**:
   ```bash
   # Port-forward to the PostgreSQL service
   kubectl port-forward service/postgres -n template-fastapi-app 5432:5432 &
   
   # Connect using the PostgreSQL password from the secret
   PGPASSWORD=$(kubectl get secret postgres-secret -n template-fastapi-app -o jsonpath='{.data.password}' | base64 --decode) \
   psql -h localhost -U postgres -d app -c 'SELECT email, is_superuser FROM "user";'
   ```

3. **From the API Logs**:
   ```bash
   # Check the database initialization job logs
   kubectl get pods -n template-fastapi-app -l component=db-init -o name | xargs kubectl logs -n template-fastapi-app
   ```

#### Changing the Default Credentials

For security in production environments, you should change the default credentials. You can do this:

1. **Via the API**:
   ```bash
   # Login first to get a token
   TOKEN=$(curl -s -X 'POST' 'http://localhost:8000/api/v1/login/access-token' \
     -H 'Content-Type: application/x-www-form-urlencoded' \
     -d 'username=admin@example.com&password=admin' | jq -r '.access_token')
   
   # Update the password
   curl -X 'PUT' 'http://localhost:8000/api/v1/users/me' \
     -H "Authorization: Bearer $TOKEN" \
     -H 'Content-Type: application/json' \
     -d '{
       "password": "new-secure-password",
       "full_name": "Updated Admin Name"
     }'
   ```

2. **Via Configuration**:
   To change the default superuser created during initialization, modify the `FIRST_SUPERUSER` and `FIRST_SUPERUSER_PASSWORD` values in the configuration.

#### Using curl

Here are some examples of common API operations using curl:

**1. Authentication (Get Access Token)**

```bash
# Login with default superuser credentials
curl -X 'POST' \
  'http://localhost:8000/api/v1/login/access-token' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'username=admin@example.com&password=admin'
```

**2. Get Current User Information**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'GET' \
  'http://localhost:8000/api/v1/users/me' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

**3. List Items**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'GET' \
  'http://localhost:8000/api/v1/items/' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

**4. Create a New Item**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'POST' \
  'http://localhost:8000/api/v1/items/' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "New Item",
    "description": "This is a new item created via API",
    "is_active": true
  }'
```

**5. List Notes**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'GET' \
  'http://localhost:8000/api/v1/notes/' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

**6. Create a New Note**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
curl -X 'POST' \
  'http://localhost:8000/api/v1/notes/' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "New Note",
    "content": "This is a new note created via API"
  }'
```

**7. Generate Seed Data**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
# This will create 5 random items and 5 random notes
curl -X 'POST' \
  'http://localhost:8000/api/v1/seed/?num_items=5&num_notes=5' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

**8. Upload Seed Data File**

```bash
# Replace YOUR_TOKEN with the access_token from the login response
# This will create items and notes from a JSON file
curl -X 'POST' \
  'http://localhost:8000/api/v1/seed/upload' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Content-Type: multipart/form-data' \
  -F 'file=@path/to/your/seed_data.json'
```

Example seed data file format:
```json
{
  "items": [
    {
      "title": "Custom Item 1",
      "description": "Description for Custom Item 1",
      "is_active": true
    }
  ],
  "notes": [
    {
      "title": "Custom Note 1",
      "content": "Content for Custom Note 1"
    }
  ]
}
```

#### Using Swagger UI

The Swagger UI provides an interactive interface for exploring and testing the API:

1. Open your browser and navigate to http://localhost:8000/docs
2. You'll see all available API endpoints organized by category
3. To authenticate:
   - Click the "Authorize" button at the top of the page (the padlock icon)
   - The OAuth2 authentication dialog will appear
   - Enter `admin@example.com` for username and `admin` for password
   - Leave client_id and client_secret fields empty
   - Click "Authorize"
   
   **If you encounter "Auth Error TypeError: Failed to fetch" errors:**
   
   This is a known issue with Swagger UI's OAuth2 form. Since Swagger UI doesn't allow adding custom authorization headers to individual requests, you have these alternatives:

   **Option 1: Use pre-acquired token with the Authorize button**
   1. First, get a token using curl:
      ```bash
      TOKEN=$(curl -s -X 'POST' \
        'http://localhost:8000/api/v1/login/access-token' \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        -d 'username=admin@example.com&password=admin' | jq -r '.access_token')
      echo $TOKEN  # Copy this token
      ```
   
   2. In Swagger UI:
      - Click the "Authorize" button (padlock icon)
      - In the "Value" field, enter: `Bearer YOUR_TOKEN` (replacing YOUR_TOKEN with the copied token)
      - Click "Authorize" and close the dialog

   **Option 2: Use alternative tools**
   - Use curl commands as shown in the previous section
   - Try API tools like [Postman](https://www.postman.com/) or [Insomnia](https://insomnia.rest/)
   - Use the ReDoc documentation at http://localhost:8000/redoc for reference

4. Once authorized, you can test any endpoint by:
   - Expanding the endpoint
   - Clicking "Try it out"
   - Filling in the required parameters
   - Clicking "Execute"

**Troubleshooting Swagger UI Issues:**

If you encounter authentication issues in Swagger UI:
1. Make sure port forwarding is active (`kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80`)
2. Check that the application pod is running (`kubectl get pods -n template-fastapi-app`)
3. Try using an incognito/private browser window
4. Disable browser extensions that might interfere with API requests
5. Use the curl commands or another API client as alternatives
6. If using Chrome, check the developer console for CORS or other errors
7. Try using a different browser

The Swagger UI also provides detailed documentation about request parameters, response models, and status codes for each endpoint.

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

#### Bazel Build Issues

If you encounter issues with Bazel builds, consider the following:

- The `run_migrations` target is tagged as `manual` because it depends on `alembic`, which might not be available in the monorepo's requirements
- When building the entire monorepo with `bazel build //...`, the `run_migrations` target will be excluded
- To build the migration tool specifically, use `bazel build //projects/template/template_fastapi_app:run_migrations`
- If you need to enable database migrations in the monorepo, run the provided helper script:

```bash
./scripts/update_requirements.sh
```

This script will add alembic to the monorepo's requirements and update the requirements_lock files.

## License

MIT

### Seeding Test Data

The application provides API endpoints to generate random test data on demand. This is useful for development, testing, and demos.

#### Generating Random Seed Data via API

You must be authenticated as a superuser to use this endpoint:

```bash
# First, get an access token
TOKEN=$(curl -s -X 'POST' \
  'http://localhost:8000/api/v1/login/access-token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'username=admin@example.com&password=admin' | jq -r '.access_token')

# Then use the token to generate seed data
curl -X 'POST' \
  'http://localhost:8000/api/v1/seed/?num_items=20&num_notes=15' \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN"
```

**Parameters:**
- `num_items` (optional): Number of random items to create (default: 10, max: 100)
- `num_notes` (optional): Number of random notes to create (default: 10, max: 100)

**Response:**
The API returns a JSON object containing:
- `items_created`: Total number of items created
- `notes_created`: Total number of notes created
- `items`: List of created items with their IDs and titles
- `notes`: List of created notes with their IDs and titles

#### Uploading Custom Seed Data via File

For more control over the seed data, you can upload a JSON file with predefined items and notes:

```bash
# First, get an access token
TOKEN=$(curl -s -X 'POST' \
  'http://localhost:8000/api/v1/login/access-token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'username=admin@example.com&password=admin' | jq -r '.access_token')

# Then upload a seed data file
curl -X 'POST' \
  'http://localhost:8000/api/v1/seed/upload' \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@./sample_seed_data.json"
```

**File Format:**
The seed data file should be a JSON file with the following structure:

```json
{
  "items": [
    {
      "title": "Item Title 1",
      "description": "Description of item 1",
      "is_active": true
    }
  ],
  "notes": [
    {
      "title": "Note Title 1",
      "content": "Content of note 1"
    }
  ]
}
```

**Required Fields:**
- For items: `title` (other fields are optional)
- For notes: `title` (other fields are optional)

**Sample Seed File:**
A sample seed data file is included in the project at `sample_seed_data.json`. You can use this as a template for creating your own seed data files.

#### Validating Seed Data

You can verify the seed data was created successfully in several ways:

**1. Check the API Response**

The seed endpoint response itself confirms what was created:

```json
{
  "items_created": 20,
  "notes_created": 15,
  "items": [
    {"id": 2, "title": "Database Solution 8622"},
    {"id": 3, "title": "IoT Platform 1831"},
    ...
  ],
  "notes": [
    {"id": 2, "title": "Implementation Strategy 6917"},
    {"id": 3, "title": "Development Roadmap 8235"},
    ...
  ]
}
```

**2. Retrieve Items via API**

```bash
# List all items (including seed data)
curl -X 'GET' \
  'http://localhost:8000/api/v1/items/' \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN"

# Get a specific item by ID
curl -X 'GET' \
  'http://localhost:8000/api/v1/items/2' \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN"
```

**3. Check Database Directly**

If you have direct database access:

```bash
# Port-forward to PostgreSQL
kubectl port-forward service/postgres -n template-fastapi-app 5432:5432 &

# Get the database password
PGPASSWORD=$(kubectl get secret postgres-secret -n template-fastapi-app -o jsonpath='{.data.password}' | base64 --decode)

# Connect and list items
psql -h localhost -U postgres -d app -c 'SELECT id, title FROM item;'

# Connect and list notes
psql -h localhost -U postgres -d app -c 'SELECT id, title FROM note;'
```

#### Using Seed Data in Development and Testing

The seed data is perfect for:

- **Development**: Quickly populate your database with realistic data
- **UI Testing**: Have varied data to test frontend components
- **API Testing**: Test filtering, pagination, and search functionality
- **Demos**: Create instant demo data when showcasing the application
- **Data Migration Testing**: Test data migration scripts with consistent data sets

**Benefits of File-Based Seeding:**
- Create consistent, repeatable test datasets
- Use version-controlled seed files to maintain test scenarios
- Share seed data files between team members
- Create different seed files for different testing scenarios (e.g., performance testing vs. functional testing)
