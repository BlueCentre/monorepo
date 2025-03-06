# Monorepo Project

[![CI](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml/badge.svg)](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml)

A modern monorepo architecture using Bazel for building and testing multiple projects across different languages and frameworks.

## Overview

This monorepo contains multiple projects organized by language and purpose. It uses Bazel as the build system to ensure consistent, reproducible builds across all projects.

## Repository Structure

```
monorepo/
├── projects/
│   ├── base/           # Base project templates and utilities
│   ├── java/           # Java applications and libraries
│   ├── py/             # Python applications and libraries
│   └── template/       # Project templates
├── third_party/        # Third-party dependencies
├── .bazelignore        # Files and directories to ignore in Bazel builds
├── .bazelrc            # Bazel configuration
├── BUILD.bazel         # Root BUILD file
├── MODULE.bazel        # Bazel module definition
└── WORKSPACE           # Bazel workspace definition (legacy)
```

## Getting Started

### Prerequisites

- [Bazel](https://bazel.build/install) (or [Bazelisk](https://github.com/bazelbuild/bazelisk) for automatic version management)
- Java JDK 11+
- Python 3.9+

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/BlueCentre/monorepo.git
   cd monorepo
   ```

2. Build all projects:
   ```bash
   bazel build //...
   ```

3. Run tests:
   ```bash
   bazel test //...
   ```

## Project Categories

### Python Projects

- **Echo FastAPI App**: A simple FastAPI application
- **Calculator CLI App**: Command-line calculator utility
- **DevOps FastAPI App**: FastAPI application with DevOps features
- **Calculator Flask App**: Flask-based calculator web application
- **Hello World App**: Basic Python application

### Java Projects

- **Simple Java App**: Basic Java application without external dependencies
- **Java Web Server**: Simple HTTP server in Java

## Development

### Adding a New Project

1. Create a new directory under the appropriate category in `projects/`
2. Add a `BUILD.bazel` file defining your build targets
3. Implement your application code
4. Add tests

### Building Specific Projects

```bash
# Build a specific Python project
bazel build //projects/py/echo_fastapi_app/...

# Build a specific Java project
bazel build //projects/java/simple_java_app/...
```

### Running Applications

```bash
# Run a Python application
bazel run //projects/py/calculator_cli_py_app

# Run a Java application
bazel run //projects/java/simple_java_app:hello
```

## CI/CD

This repository uses GitHub Actions for continuous integration. The workflow is defined in `.github/workflows/ci.yml`.

The CI pipeline:
1. Builds all projects
2. Runs all tests
3. Reports build and test results

## Known Issues

See [BUILD_FIXES.md](../BUILD_FIXES.md) for information about current build issues and their workarounds.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details. 