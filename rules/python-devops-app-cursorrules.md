# Python DevOps App - Rules for AI

This file provides guidance for working with the Python DevOps App project, which implements a simple HTTP server without external dependencies.

## Project Structure

```
projects/py/devops_fastapi_app/
├── __init__.py                # Package initialization
├── app/                       # Application logic
│   ├── __init__.py
│   └── main.py                # DevOpsApp implementation
├── bin/                       # Executable scripts
│   ├── __init__.py
│   └── run_bin.py             # HTTP server implementation
├── tests/                     # Test files
│   └── main_test.py           # Unit tests for the application
├── BUILD.bazel                # Bazel build configuration
├── README.md                  # Project documentation
└── .cursorrules               # Rules for AI
libs/py/devops/models/         # DevOps models
└── devops.py                  # DevOps class definitions
```

## General Guidelines

1. This project avoids external dependencies like FastAPI and uvicorn
2. Use only Python standard library modules for HTTP server functionality
3. Maintain backward compatibility with the existing API endpoints
4. Keep the code simple and well-documented
5. Follow PEP 8 guidelines for Python code
6. Use docstrings for all functions and classes
7. Handle exceptions gracefully to prevent server crashes

## Implementation Details

### HTTP Server

The application implements a simple HTTP server using Python's built-in `http.server` module. It provides several endpoints:

- `/`: Root endpoint that returns a simple "alive" message
- `/status`: Returns the current status and version of the application
- `/healthcheck`: Returns health status information
- `/devops/{id}`: Returns information about a specific DevOps engineer
- `/devops/random/{name}`: Returns information about a randomly selected DevOps engineer type

```python
# bin/run_bin.py
import http.server
import socketserver
import json
from urllib.parse import urlparse

class DevOpsHandler(http.server.SimpleHTTPRequestHandler):
    """Simple HTTP request handler for DevOps App."""
    
    def do_GET(self):
        """Handle GET requests."""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        if path == '/':
            self.send_response_json(app.get_root())
        elif path == '/status':
            self.send_response_json(app.get_status())
        # Additional routes...
    
    def send_response_json(self, data):
        """Send a JSON response."""
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

def main():
    """Run the server."""
    port = 9090
    handler = DevOpsHandler
    
    with socketserver.TCPServer(("", port), handler) as httpd:
        print(f"Server started at http://localhost:{port}")
        httpd.serve_forever()
```

### Business Logic

The business logic is implemented in the `DevOpsApp` class:

```python
# app/main.py
class DevOpsApp:
    """DevOps App implementation."""
    
    def __init__(self):
        """Initialize the app."""
        logger.info("=== [Starting DevOps App] ===")
    
    def get_root(self):
        """Get the root endpoint."""
        return {"message": "I am alive!!!"}
    
    def get_status(self):
        """Get the status endpoint."""
        return {"status": "UP", "version": "0.1.2"}
    
    def get_healthcheck(self):
        """Get the healthcheck endpoint."""
        return {"status": "UP", "msg": "degraded"}
    
    def get_devops(self, devops_id):
        """Get a devops."""
        platform = PlatformOrganization(InfrastructureEngineer)
        devops = platform.request_devops(devops_id)
        return {"devops": str(devops)}
    
    def get_devops_random_item(self, name):
        """Get a random devops."""
        # Implementation details...
```

### Testing

The application includes unit tests that use Python's built-in `unittest` module and mock objects:

```python
# tests/main_test.py
import unittest
from unittest.mock import patch, MagicMock

from projects.py.devops_fastapi_app.bin.run_bin import DevOpsApp

class TestDevOpsApp(unittest.TestCase):
    def setUp(self):
        self.app = DevOpsApp()
    
    def test_get_root(self):
        response = self.app.get_root()
        self.assertEqual(response, {"message": "I am alive!!!"})
    
    @patch('projects.py.devops_fastapi_app.bin.run_bin.PlatformOrganization')
    def test_get_devops(self, mock_platform_org):
        # Setup mock
        mock_devops = MagicMock()
        mock_devops.__str__.return_value = "InfrastructureEngineer<TestUser>"
        mock_platform_instance = MagicMock()
        mock_platform_instance.request_devops.return_value = mock_devops
        mock_platform_org.return_value = mock_platform_instance
        
        # Test
        response = self.app.get_devops("TestUser")
        self.assertEqual(response, {"devops": "InfrastructureEngineer<TestUser>"})
```

### DevOps Models

The application uses the DevOps models from the `libs/py/devops/models/devops.py` module:

```python
# libs/py/devops/models/devops.py
class DevOps:
    def __init__(self, name: str) -> None:
        self.name = name

    def __str__(self) -> str:
        raise NotImplementedError

    def speak(self) -> None:
        raise NotImplementedError

# Child Classes
class InfrastructureEngineer(DevOps):
    def __str__(self) -> str:
        return f"InfrastructureEngineer<{self.name}>"

    def speak(self) -> None:
        print("How would you like your cloud today?")

# Additional DevOps classes...

# Factory
class PlatformOrganization:
    """Platform Organization"""

    def __init__(self, platform_factory: Type[DevOps]) -> None:
        self.devops_factory = platform_factory

    def request_devops(self, name: str) -> DevOps:
        devops = self.devops_factory(name)
        print(f"Here is your awesome {devops}")
        return devops
```

## Known Issues

- The import from app.main may fail if the module structure doesn't match expectations
- Fix by ensuring app.main.py exports an 'app' object with the required methods
- The server may have port conflicts - use a different port if 8080 or 9090 are in use

## Build System

- The project uses Bazel for building and testing
- All Python dependencies are commented out in BUILD.bazel files
- Use py_library, py_binary, and py_test rules for defining targets
- The application should be runnable with: `bazel run //projects/py/devops_fastapi_app:run_bin`
- Tests can be run with: `bazel test //projects/py/devops_fastapi_app:main_test`

## Error Handling

- Use appropriate HTTP status codes for error responses
- Log errors and important events using the logging module
- Handle exceptions gracefully to prevent server crashes
- Implement try-except blocks for operations that might fail

## API Guidelines

- All endpoints should return JSON responses
- Use consistent response formats across all endpoints
- Include appropriate status codes and error messages
- Document the API endpoints and their expected inputs/outputs

## How to Use

1. Create a `.cursorrules` file in the root of your DevOps App project
2. Copy the content from this file
3. Customize it to match your project's specific structure and requirements
4. Commit the file to your repository

## Benefits

- Consistent project structure
- Standardized implementation patterns
- Better code organization
- Improved maintainability
- Easier onboarding for new developers
- Enhanced collaboration with Cursor AI

## Additional Resources

- [Python HTTP Server Documentation](https://docs.python.org/3/library/http.server.html)
- [Python socketserver Documentation](https://docs.python.org/3/library/socketserver.html)
- [Python unittest Documentation](https://docs.python.org/3/library/unittest.html)
- [Python unittest.mock Documentation](https://docs.python.org/3/library/unittest.mock.html)
- [Bazel Documentation](https://bazel.build/docs)
- [PEP 8 Style Guide](https://peps.python.org/pep-0008/) 