# Echo FastAPI App

A lightweight HTTP server that mimics FastAPI functionality using only Python's standard library.

## Overview

This project demonstrates how to create a simple HTTP server that provides JSON responses without relying on external dependencies like FastAPI or uvicorn. It's designed to be minimal, easy to understand, and compatible with the Bazel build system.

## Features

- Pure Python implementation using only standard library modules
- JSON API endpoints (`/` and `/status`)
- Bazel build system integration
- Comprehensive test suite using Python's unittest module

## Project Structure

```
echo_fastapi_app/
├── app/
│   ├── __init__.py
│   └── web_app.py       # Mock FastAPI implementation
├── bin/
│   ├── __init__.py
│   └── run_bin.py       # HTTP server implementation
├── tests/
│   ├── __init__.py
│   └── test.py          # Test suite
├── __init__.py
├── .cursorrules         # Guidelines for AI assistance
├── BUILD.bazel          # Bazel build configuration
└── README.md            # This file
```

## Getting Started

### Prerequisites

- Python 3.6+
- Bazel build system

### Running the Server

Using Bazel:

```bash
bazel run //projects/py/echo_fastapi_app:run_bin
```

Directly with Python:

```bash
python3 projects/py/echo_fastapi_app/bin/run_bin.py
```

The server will start on port 5678 by default.

### API Endpoints

- `GET /`: Returns a simple "I am alive" message
- `GET /status`: Returns a status object with "UP" status and version information

### Running Tests

```bash
bazel test //projects/py/echo_fastapi_app/...
```

## Development Guidelines

1. Use only Python standard library modules
2. Maintain backward compatibility with existing endpoints
3. Follow PEP 8 style guidelines
4. Write comprehensive tests for new functionality
5. Keep the codebase simple and well-documented

## License

This project is licensed under the MIT License - see the LICENSE file for details.
