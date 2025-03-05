# Calculator App

A lightweight HTTP server that provides a simple calculator web interface using only Python's standard library.

## Overview

This project demonstrates how to create a simple HTTP server that provides a calculator interface without relying on external dependencies like Flask. It's designed to be minimal, easy to understand, and compatible with the Bazel build system.

## Features

- Pure Python implementation using only standard library modules
- Simple web interface for addition operations
- Bazel build system integration
- Integration with a separate calculator library

## Project Structure

```
calculator_flask_app/
├── app/
│   └── app.py           # HTTP server implementation
├── .cursorrules         # Guidelines for AI assistance
├── BUILD.bazel          # Bazel build configuration
└── README.md            # This file
```

The calculator functionality is provided by:

```
libs/py/calculator/
├── models/
│   └── calculator.py    # Calculator class implementation
└── BUILD.bazel          # Bazel build configuration
```

## Getting Started

### Prerequisites

- Python 3.6+
- Bazel build system

### Running the App

Using Bazel:

```bash
bazel run //projects/py/calculator_flask_app:app_bin
```

Directly with Python:

```bash
python3 projects/py/calculator_flask_app/app/app.py
```

The server will start on port 8080 by default.

### Using the Calculator

1. Open your browser and navigate to http://localhost:8080/
2. You'll see a random calculation example
3. Use the form to enter two numbers and click "Add"
4. The result will be displayed on the page

## Development Guidelines

1. Use only Python standard library modules
2. Maintain backward compatibility with existing endpoints
3. Follow PEP 8 style guidelines
4. Keep the code simple and well-documented

## License

This project is licensed under the MIT License - see the LICENSE file for details. 