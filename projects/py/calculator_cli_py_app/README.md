# Calculator CLI App

A simple command-line calculator application demonstrating basic arithmetic operations.

## Features

- Basic arithmetic operations (add, subtract, multiply, divide)
- Interactive CLI interface
- Random calculation examples
- Integration with shared calculator library

## Usage

```bash
# Build the application
bazel build //projects/py/calculator_cli_py_app:app_bin

# Run the application
bazel run //projects/py/calculator_cli_py_app:app_bin

# Run tests
bazel test //projects/py/calculator_cli_py_app:app_test
```

## Development

```bash
# Run linting (if pre-commit is set up)
pre-commit run --all-files

# Run tests with coverage
python -m pytest tests/ --cov=app --cov-report=term-missing
```

## Project Structure

```
calculator_cli_py_app/
├── app/
│   ├── __init__.py
│   └── app.py          # Main application logic
├── tests/
│   ├── __init__.py
│   └── test_app.py     # Unit tests
├── BUILD.bazel         # Bazel build configuration
├── README.md          # This file
├── pytest.ini        # pytest configuration
└── pyproject.toml     # Python project configuration
```

## Dependencies

- Uses shared calculator library from `//libs/py/calculator`
- Python 3.11+

## Monorepo Integration

This application is fully integrated with the monorepo build system using Bazel and demonstrates how to use shared libraries across projects.

```bash
# Build everything in the monorepo
bazel build //...

# Test everything in the monorepo
bazel test //...

# Build and run this specific application
bazel run //projects/py/calculator_cli_py_app:app_bin
```

This CLI application showcases:
- Integration with shared calculator library from `//libs/py/calculator`
- Consistent build patterns across the monorepo
- Proper dependency management using Bazel