# DevOps FastAPI App

A simple HTTP server implementation that simulates a DevOps API without external dependencies.

## Overview

This project demonstrates how to implement a web server using only Python's standard library modules, avoiding external dependencies like FastAPI and uvicorn. It provides a RESTful API for DevOps-related operations.

## Features

- Simple HTTP server using Python's built-in `http.server` module
- JSON-formatted responses
- Multiple endpoints for different DevOps operations
- Error handling and logging

## API Endpoints

- `/`: Root endpoint that returns a simple "alive" message
- `/status`: Returns the current status and version of the application
- `/healthcheck`: Returns health status information
- `/devops/{id}`: Returns information about a specific DevOps engineer
- `/devops/random/{name}`: Returns information about a randomly selected DevOps engineer type

## Running the Application

To run the application using Bazel:

```bash
bazel run //projects/py/devops_fastapi_app:run_bin
```

The server will start on port 9090 by default. You can access it at http://localhost:9090.

## Testing the API

You can test the API using curl:

```bash
# Test the root endpoint
curl http://localhost:9090/

# Test the status endpoint
curl http://localhost:9090/status

# Test the devops endpoint
curl http://localhost:9090/devops/John

# Test the random devops endpoint
curl http://localhost:9090/devops/random/Alice
```

## Running Tests

The project includes unit tests for the DevOpsApp class. To run the tests:

```bash
bazel test //projects/py/devops_fastapi_app:main_test
```

The tests use Python's built-in `unittest` module and mock objects to test the application's functionality without external dependencies.

## Implementation Notes

- The application uses a custom HTTP request handler (`DevOpsHandler`) to process requests
- The business logic is implemented in the `DevOpsApp` class
- The application uses the DevOps models from the `libs/py/devops/models/devops.py` module
- Error handling is implemented to gracefully handle exceptions

## Dependencies

- Python 3.11+
- Bazel build system
- No external Python packages required
