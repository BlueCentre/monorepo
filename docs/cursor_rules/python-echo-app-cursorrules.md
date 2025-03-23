# Python Echo App - Rules for AI

This file provides guidance for working with the Python Echo App project, a simple HTTP server implementation that avoids external dependencies.

## Project Structure

- `projects/py/echo_fastapi_app/app/web_app.py`: Contains the mock FastAPI implementation
- `projects/py/echo_fastapi_app/bin/run_bin.py`: Simple HTTP server implementation
- `projects/py/echo_fastapi_app/tests/test.py`: Test file for the application
- `projects/py/echo_fastapi_app/BUILD.bazel`: Bazel build configuration

## General Guidelines

1. This project intentionally avoids external dependencies like FastAPI and uvicorn
2. Use only Python standard library modules for all functionality
3. Maintain backward compatibility with the existing API endpoints
4. Keep the code simple and well-documented

## Implementation Details

- The application implements a simple HTTP server using Python's built-in `http.server` module
- It provides two endpoints: `/` and `/status`
- The `MockFastAPI` class in `web_app.py` simulates FastAPI functionality without the dependency
- All responses should be JSON-formatted

## Example .cursorrules File

```
// Python Echo App - Rules for AI
// This file provides guidance for working with the Python Echo App project

// Project Structure
// - projects/py/echo_fastapi_app/app/web_app.py: Contains the mock FastAPI implementation
// - projects/py/echo_fastapi_app/bin/run_bin.py: Simple HTTP server implementation
// - projects/py/echo_fastapi_app/tests/test.py: Test file for the application

// General Guidelines
// 1. This project intentionally avoids external dependencies like FastAPI and uvicorn
// 2. Use only Python standard library modules for all functionality
// 3. Maintain backward compatibility with the existing API endpoints
// 4. Keep the code simple and well-documented

// Implementation Details
// - The application implements a simple HTTP server using Python's built-in http.server module
// - It provides two endpoints: "/" and "/status"
// - The MockFastAPI class in web_app.py simulates FastAPI functionality without the dependency
// - All responses should be JSON-formatted

// Testing
// - Tests should not rely on external testing libraries when possible
// - Use Python's built-in unittest module for testing
// - Ensure tests can run in the Bazel build environment

// Build System
// - The project uses Bazel for building and testing
// - All Python dependencies are commented out in BUILD.bazel files
// - Use py_library, py_binary, and py_test rules for defining targets
// - The application should be runnable with: bazel run //projects/py/echo_fastapi_app:run_bin

// Code Style
// - Follow PEP 8 guidelines for Python code
// - Use docstrings for all functions and classes
// - Prefer explicit imports over wildcard imports
// - Keep functions small and focused on a single responsibility

// Error Handling
// - Use appropriate HTTP status codes for error responses
// - Log errors and important events using the logging module
// - Handle exceptions gracefully to prevent server crashes

// Performance Considerations
// - The server should handle multiple concurrent requests
// - Keep response times minimal
// - Avoid unnecessary computation in request handlers
```

## How to Use

1. Copy the above `.cursorrules` content to a file named `.cursorrules` in the root of your repository.
2. Customize it to match your project's specific needs and conventions.
3. Commit the file to your repository.

The content of the `.cursorrules` file will be appended to the global "Rules for AI" settings in Cursor, providing project-specific guidance to Cursor AI.

## Benefits

- Helps Cursor AI understand the project's structure and purpose
- Provides context about the intentional avoidance of external dependencies
- Guides Cursor AI to suggest standard library solutions instead of third-party packages
- Ensures consistent code style and error handling across the project
- Improves code generation and understanding for this specific project type

## Additional Resources

- [Python Standard Library Documentation](https://docs.python.org/3/library/index.html)
- [http.server Module Documentation](https://docs.python.org/3/library/http.server.html)
- [Bazel Python Rules](https://bazel.build/reference/be/python)
- [PEP 8 Style Guide](https://peps.python.org/pep-0008/) 