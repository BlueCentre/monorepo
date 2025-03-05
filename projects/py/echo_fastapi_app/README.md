# Echo FastAPI App

A lightweight HTTP server built with FastAPI that provides simple JSON API endpoints. This project demonstrates how to build a modern API using FastAPI, Pydantic, and Uvicorn.

## Features

- **FastAPI Framework**: Modern, fast web framework for building APIs with Python
- **Pydantic Models**: Type validation and data serialization
- **JSON API Endpoints**: Clean, RESTful API design
- **Swagger Documentation**: Auto-generated API documentation
- **Comprehensive Test Suite**: Using FastAPI's TestClient
- **Bazel Build System**: Integrated with Bazel for building and testing
- **Modular Architecture**: Separation of models, routes, and application logic

## Project Structure

```
projects/py/echo_fastapi_app/
├── app/
│   ├── __init__.py
│   ├── models.py      # Pydantic models for the application
│   ├── routes.py      # Route handlers for the application
│   └── web_app.py     # Main FastAPI application
├── bin/
│   └── run_bin.py     # Server runner using uvicorn
├── tests/
│   └── test.py        # Tests using FastAPI TestClient
├── BUILD.bazel        # Bazel build configuration
├── .cursorrules       # Rules for AI assistance
└── README.md          # This file
```

## Getting Started

### Prerequisites

- Python 3.11 or higher
- Bazel build system
- FastAPI, Pydantic, and Uvicorn packages

### Running the Server

Using Bazel:

```bash
bazel run //projects/py/echo_fastapi_app:run_bin
```

Directly with Python:

```bash
cd projects/py/echo_fastapi_app
python -m bin.run_bin
```

The server will start on http://localhost:8000 by default.

### API Endpoints

- `GET /`: Root endpoint that returns a simple "I am alive" message
- `GET /status`: Returns the application status and version
- `GET /health`: Returns detailed health information
- `GET /echo/{message}`: Returns the provided message
- `GET /docs`: Swagger UI documentation
- `GET /redoc`: ReDoc documentation

### Running Tests

Using Bazel:

```bash
bazel test //projects/py/echo_fastapi_app:test
```

Directly with Python:

```bash
cd projects/py/echo_fastapi_app
python -m unittest discover tests
```

## Development Guidelines

1. Use FastAPI best practices for route and model definitions
2. Maintain backward compatibility with existing API endpoints
3. Use standard library modules where possible
4. Follow PEP 8 style guidelines
5. Write comprehensive tests for all new functionality
6. Document all functions, classes, and modules with docstrings
7. Use type hints for all function parameters and return values

## Testing Strategy

The project uses FastAPI's TestClient to simulate HTTP requests without starting a real server. Tests verify both HTTP status codes and response content/structure. Each endpoint has dedicated test methods to ensure proper functionality.

## Performance Considerations

- The server handles multiple concurrent requests
- Uses async/await for I/O-bound operations
- Minimizes response times
- Avoids unnecessary computation in request handlers

## Documentation

API documentation is automatically generated and available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## License

This project is licensed under the MIT License - see the LICENSE file for details.
