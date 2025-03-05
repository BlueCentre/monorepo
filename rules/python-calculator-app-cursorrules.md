# Python Calculator App - Rules for AI

This file provides guidance for working with the Python Calculator App project, a lightweight HTTP server that provides a simple calculator web interface using only Python's standard library.

## Project Structure

```
calculator_flask_app/
├── app/
│   └── app.py           # HTTP server implementation
├── .cursorrules         # Guidelines for AI assistance
├── BUILD.bazel          # Bazel build configuration
└── README.md            # Project documentation
```

The calculator functionality is provided by:

```
libs/py/calculator/
├── models/
│   └── calculator.py    # Calculator class implementation
└── BUILD.bazel          # Bazel build configuration
```

## General Guidelines

1. This project intentionally avoids external dependencies like Flask
2. Use only Python standard library modules for all functionality
3. Maintain backward compatibility with the existing API endpoints
4. Keep the code simple and well-documented

## Implementation Details

- The application implements a simple HTTP server using Python's built-in `http.server` module
- It provides two endpoints: "/" and "/calculate"
- The server runs on port 8080 by default
- The `CalculatorHandler` class extends `http.server.SimpleHTTPRequestHandler` to handle HTTP requests
- The calculator functionality is imported from the calculator library

## Example .cursorrules Content

```
// Python Calculator App - Rules for AI
// This file provides guidance for working with the Python Calculator App project

// Project Structure
// - projects/py/calculator_flask_app/app/app.py: Contains the HTTP server implementation
// - projects/py/calculator_flask_app/BUILD.bazel: Bazel build configuration
// - libs/py/calculator/models/calculator.py: Calculator class implementation

// General Guidelines
// 1. This project intentionally avoids external dependencies like Flask
// 2. Use only Python standard library modules for all functionality
// 3. Maintain backward compatibility with the existing API endpoints
// 4. Keep the code simple and well-documented

// Implementation Details
// - The application implements a simple HTTP server using Python's built-in http.server module
// - It provides two endpoints: "/" and "/calculate"
// - The server runs on port 8080 by default
// - The CalculatorHandler class extends http.server.SimpleHTTPRequestHandler to handle HTTP requests
// - The calculator functionality is imported from the calculator library

// Build System
// - The project uses Bazel for building and testing
// - Use py_library, py_binary, and py_test rules for defining targets
// - The application should be runnable with: bazel run //projects/py/calculator_flask_app:app_bin

// Code Style
// - Follow PEP 8 guidelines for Python code
// - Use docstrings for all functions and classes
// - Prefer explicit imports over wildcard imports
// - Keep functions small and focused on a single responsibility

// Error Handling
// - Use appropriate HTTP status codes for error responses
// - Log errors and important events using the logging module
// - Handle exceptions gracefully to prevent server crashes

// UI Guidelines
// - Keep the HTML interface simple and user-friendly
// - Use basic CSS for styling
// - Ensure the form is accessible and easy to use
// - Display clear error messages when input validation fails
```

## How to Use

1. Copy the content from the example section above
2. Create a file named `.cursorrules` in the root of your calculator app repository
3. Paste and customize the content to match your project's specific needs
4. Commit the file to your repository

The content will be appended to the global "Rules for AI" settings in Cursor, providing project-specific guidance to Cursor AI.

## Benefits

- Provides context about the project's structure and purpose
- Guides Cursor AI to use only standard library modules
- Ensures consistent code style and error handling
- Helps maintain backward compatibility with existing endpoints
- Improves code generation and understanding

## Additional Resources

- [Python http.server documentation](https://docs.python.org/3/library/http.server.html)
- [Bazel Python rules](https://bazel.build/reference/be/python)
- [PEP 8 Style Guide for Python Code](https://peps.python.org/pep-0008/)
- [Cursor AI documentation](https://cursor.sh/docs) 