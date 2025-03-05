# DevOps FastAPI App

A modern FastAPI implementation for a DevOps API that provides information about various DevOps roles.

## Features

- Built with FastAPI, a modern, high-performance web framework for building APIs with Python
- Structured with a modular organization separating models, routes, and the main app
- JSON-formatted responses with Pydantic models for validation and serialization
- Multiple endpoints for different DevOps operations
- Comprehensive error handling with HTTP exceptions
- Interactive API documentation with Swagger UI and ReDoc
- Asynchronous request handling
- Complete test suite using FastAPI's TestClient

## API Endpoints

- `/`: Root endpoint that returns a simple alive message
- `/status`: Returns the application status and version
- `/healthcheck`: Returns detailed health status information
- `/devops/{id}`: Returns information about a specific DevOps role
- `/devops/random/{name}`: Returns information about a random DevOps role with the given name

## Running the Application

Using Bazel:

```bash
bazel run //projects/py/devops_fastapi_app:run_bin
```

The server will start on port 9090 by default.

## Testing the API

Use curl or any HTTP client to test the API:

```bash
# Test the root endpoint
curl http://localhost:9090/

# Test the status endpoint
curl http://localhost:9090/status

# Test the healthcheck endpoint
curl http://localhost:9090/healthcheck

# Test getting a specific DevOps role
curl http://localhost:9090/devops/CloudEngineer

# Test getting a random DevOps role
curl http://localhost:9090/devops/random/DataSpecialist
```

## Running Tests

Run the unit tests for the DevOps FastAPI App using:

```bash
bazel test //projects/py/devops_fastapi_app:main_test
```

The tests use FastAPI's TestClient to make requests to the application without starting an actual server.

## Implementation Notes

- The application is built using FastAPI, making it easy to create fast, modern API endpoints
- The modular structure separates concerns:
  - `app/models.py`: Pydantic models for request/response validation
  - `app/routes.py`: API route handlers
  - `app/web_app.py`: Main FastAPI application setup
  - `bin/run_bin.py`: Server runner using uvicorn
- The application integrates with the DevOps library to provide information about different DevOps roles
- CORS middleware is configured to allow cross-origin requests
- API documentation is available at `/docs` (Swagger UI) and `/redoc` (ReDoc)

## Dependencies

- Python 3.11+
- FastAPI
- Pydantic
- Uvicorn
- Bazel (for building and testing)

## API Documentation

Once the server is running, you can access the interactive API documentation at:

- Swagger UI: http://localhost:9090/docs
- ReDoc: http://localhost:9090/redoc

The documentation provides detailed information about each endpoint, including request parameters and response models.
