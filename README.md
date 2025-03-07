# Monorepo Project

[![CI](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml/badge.svg)](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml)
[![Documentation Status](https://img.shields.io/badge/docs-up--to--date-brightgreen)](https://github.com/BlueCentre/monorepo/wiki)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

A modern monorepo architecture using Bazel for building and testing multiple projects across different languages and frameworks. This repository contains reusable components, project templates, and production-ready applications organized in a structured way.

## Overview

This monorepo contains multiple projects organized by language and purpose. It uses Bazel as the build system to ensure consistent, reproducible builds across all projects. The repository structure facilitates code sharing, standardization, and simplified dependency management across multiple applications and services.

### Key Features

- **Unified Build System**: Consistent builds using Bazel across all projects
- **Cross-Language Support**: Projects in Python, Java, and more
- **Standardized Templates**: Common project templates for quick bootstrapping
- **Integrated Testing**: Streamlined testing infrastructure
- **Shared Libraries**: Common code shared across projects
- **CI/CD Integration**: GitHub Actions workflows for continuous integration

## Repository Structure

```
monorepo/
├── projects/                 # All projects organized by category
│   ├── base/                 # Base project templates and utilities
│   ├── java/                 # Java applications and libraries
│   │   ├── simple_java_app/  # Basic Java application
│   │   └── java_web_server/  # Simple HTTP server in Java
│   ├── py/                   # Python applications and libraries
│   │   ├── calculator_cli_app/      # CLI calculator utility
│   │   ├── calculator_flask_app/    # Flask calculator web app
│   │   ├── devops_fastapi_app/      # FastAPI app with DevOps features
│   │   ├── echo_fastapi_app/        # Simple FastAPI application
│   │   └── hello_world_app/         # Basic Python application
│   └── template/             # Project templates
│       └── template_fastapi_app/    # FastAPI application template with PostgreSQL
├── shared/                   # Shared libraries and utilities
│   ├── java/                 # Shared Java libraries
│   └── python/               # Shared Python libraries
├── third_party/              # Third-party dependencies
├── tools/                    # Development and build tools
├── .bazelignore              # Files and directories to ignore in Bazel builds
├── .bazelrc                  # Bazel configuration
├── BUILD.bazel               # Root BUILD file
├── MODULE.bazel              # Bazel module definition
└── WORKSPACE                 # Bazel workspace definition (legacy)
```

## Project Catalog

| Project | Description | Technologies | Status |
|---------|-------------|--------------|--------|
| [template_fastapi_app](./projects/template/template_fastapi_app) | FastAPI application template with PostgreSQL, JWT auth, and OpenTelemetry | Python, FastAPI, PostgreSQL, K8s | ✅ Active |
| [echo_fastapi_app](./projects/py/echo_fastapi_app) | Simple FastAPI application | Python, FastAPI | ✅ Active |
| [calculator_cli_app](./projects/py/calculator_cli_app) | Command-line calculator utility | Python | ✅ Active |
| [devops_fastapi_app](./projects/py/devops_fastapi_app) | FastAPI application with DevOps features | Python, FastAPI | ✅ Active |
| [calculator_flask_app](./projects/py/calculator_flask_app) | Flask-based calculator web application | Python, Flask | ✅ Active |
| [hello_world_app](./projects/py/hello_world_app) | Basic Python application | Python | ✅ Active |
| [simple_java_app](./projects/java/simple_java_app) | Basic Java application without external dependencies | Java | ✅ Active |
| [java_web_server](./projects/java/java_web_server) | Simple HTTP server in Java | Java | ✅ Active |

## Featured Project: FastAPI Template App

![FastAPI](https://img.shields.io/badge/FastAPI-0.103.1-009688.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791.svg)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5.svg)

The [FastAPI Template App](./projects/template/template_fastapi_app) provides a production-ready template for building robust API services with FastAPI and PostgreSQL. It includes:

### Key Features

- **Complete API Structure**: Well-organized project structure following best practices
- **Authentication**: JWT-based authentication with OAuth2 password flow
- **Database Integration**: PostgreSQL with SQLAlchemy ORM and Alembic migrations
- **Kubernetes Deployment**: Ready-to-use Kubernetes manifests with Skaffold
- **OpenTelemetry**: Integrated observability for distributed tracing
- **API Documentation**: Automatic documentation with Swagger UI and ReDoc
- **Notes API**: Full-featured notes management with CRUD operations
- **Items API**: Example API for managing items with owner relationships
- **Seed Data Utilities**: Tools for generating test data for development and demos

### Getting Started

```bash
# Navigate to the project
cd projects/template/template_fastapi_app

# Deploy to Kubernetes
./skaffold.sh run

# Set up port forwarding
kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80
```

Access the API documentation at http://localhost:8000/docs

### Recent Improvements

- Added complete Notes API with full CRUD operations
- Enhanced seed data utilities to support both Notes and Items
- Added file upload endpoint for seed data
- Updated documentation for testing with ReDoc and Swagger UI
- Improved error handling and validation

## Getting Started

### Prerequisites

- [Bazel](https://bazel.build/install) (or [Bazelisk](https://github.com/bazelbuild/bazelisk) for automatic version management)
- Java JDK 11+
- Python 3.9+
- Docker (for containerized applications)
- Kubernetes (for deployment of some applications)

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

### Quick Start

To quickly get started with a specific project:

```bash
# Python FastAPI project
cd projects/template/template_fastapi_app
./skaffold.sh dev  # Start the development environment

# Python CLI app
bazel run //projects/py/calculator_cli_app

# Java application
bazel run //projects/java/simple_java_app:hello
```

## Development Workflow

### Branch Naming Conventions

- Feature branches: `feature/name-of-feature`
- Bug fixes: `fix/issue-description`
- Documentation updates: `docs/what-was-updated`
- Release branches: `release/version-number`

### Typical Development Workflow with Skaffold

Skaffold enables a highly efficient development workflow for containerized applications with live reload capabilities. Here's a step-by-step guide for a typical development session:

#### Initial Setup

1. **Clone the repository and navigate to the project**:
   ```bash
   git clone https://github.com/BlueCentre/monorepo.git
   cd monorepo
   ```

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/my-new-feature
   ```

3. **Navigate to the project you want to work on**:
   ```bash
   cd projects/template/template_fastapi_app
   ```

#### Development with Live Reload

4. **Start Skaffold in dev mode**:
   ```bash
   ./skaffold.sh dev
   ```
   This will:
   - Build the container image
   - Deploy to your local Kubernetes cluster
   - Set up file watching for live reload
   - Stream logs from your application

5. **Set up port forwarding** (in a separate terminal):
   ```bash
   kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80
   ```

6. **Access your application**:
   - API: http://localhost:8000/api/v1
   - Documentation: http://localhost:8000/docs

7. **Make code changes**:
   - Edit any Python files, templates, or static assets
   - Skaffold will automatically:
     - Detect the changes
     - Rebuild the container with your changes
     - Update the deployment in Kubernetes
     - Your changes will be reflected within seconds

#### Testing and Debugging

8. **View application logs in real-time**:
   Skaffold automatically streams logs from your application in the terminal where you started `skaffold dev`.

9. **Run tests in a separate terminal**:
   ```bash
   # For Python applications
   cd projects/template/template_fastapi_app
   pytest

   # For Bazel-built applications
   bazel test //projects/path/to/project/...
   ```

10. **Debug issues**:
    - Check the logs for errors
    - Use your browser's developer tools
    - For FastAPI applications, errors will be shown in the browser and in the logs

#### Finalizing Changes

11. **Stop Skaffold when you're done** (Ctrl+C in the terminal running Skaffold)

12. **Commit your changes**:
    ```bash
    git add .
    git commit -m "Add my new feature"
    ```

13. **Push your branch and create a pull request**:
    ```bash
    git push origin feature/my-new-feature
    ```
    Then create a pull request through the GitHub interface.

#### Example: Modifying the FastAPI Template App

Here's a specific example workflow for modifying the FastAPI Template application:

```bash
# Clone and set up
git clone https://github.com/BlueCentre/monorepo.git
cd monorepo
git checkout -b feature/enhanced-api

# Navigate to the FastAPI project
cd projects/template/template_fastapi_app

# Start development mode
./skaffold.sh dev

# In a separate terminal, set up port forwarding
kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80

# Make changes to the API (example: add a new endpoint)
# Edit app/api/v1/endpoints/items.py

# Test your changes by accessing http://localhost:8000/docs
# Skaffold will automatically rebuild and redeploy

# When finished, stop Skaffold (Ctrl+C)
# Commit and push
git add .
git commit -m "Add enhanced item filtering"
git push origin feature/enhanced-api
```

#### Tips for Efficient Development

- **Keep Skaffold running** while you make changes for the fastest feedback loop
- **Monitor resource usage** on your local Kubernetes cluster
- **Use API testing tools** like Postman or the built-in Swagger UI
- **Consider using database migrations** for schema changes
- **Commit often** to track your progress
- **Clean up resources** when you're done by running `skaffold delete`

### Pull Request Process

1. Create a branch from `main` using the naming conventions above
2. Make your changes, ensuring tests pass locally
3. Push your branch and create a pull request
4. Wait for CI checks to pass
5. Request a code review from team members
6. Address feedback and update the pull request as needed
7. Once approved, merge the pull request

### Testing Requirements

- All new features must have tests
- All existing tests must pass before a PR can be merged
- Integration tests should be added for cross-component functionality
- Performance tests should be added for performance-critical components

## Building and Running Projects

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
bazel run //projects/py/calculator_cli_app

# Run a Java application
bazel run //projects/java/simple_java_app:hello

# Run a containerized application
cd projects/template/template_fastapi_app
./skaffold.sh run  # Deploy to Kubernetes
```

### Adding a New Project

1. Create a new directory under the appropriate category in `projects/`
2. Add a `BUILD.bazel` file defining your build targets
3. Implement your application code
4. Add tests
5. Update the Project Catalog in this README with your new project

## Technology Stack

### Core Technologies

- **Build System**: Bazel
- **Languages**: Python, Java
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions

### Python Stack

- **Web Frameworks**: FastAPI, Flask
- **Database ORM**: SQLAlchemy
- **Authentication**: JWT
- **Testing**: pytest
- **Documentation**: Swagger UI, ReDoc

### Java Stack

- **Build Tools**: Gradle (via Bazel)
- **Frameworks**: Standard Java libraries
- **Testing**: JUnit

## Documentation

- [Project Wiki](https://github.com/BlueCentre/monorepo/wiki) - Detailed documentation for all projects
- [Contribution Guide](CONTRIBUTING.md) - Guidelines for contributing to the repository
- [Architecture Diagrams](docs/architecture/) - System architecture and design documents
- [Development Guide](docs/development/) - Detailed developer documentation

## CI/CD

This repository uses GitHub Actions for continuous integration. The workflow is defined in `.github/workflows/ci.yml`.

The CI pipeline:
1. Builds all projects
2. Runs all tests
3. Builds container images when applicable
4. Pushes container images to the registry for deployable applications
5. Reports build and test results

## Troubleshooting

### Common Issues

- **Bazel cache issues**: Run `bazel clean --expunge` to clear the cache
- **Dependency conflicts**: Check the `MODULE.bazel` file for version mismatches
- **Python environment issues**: Ensure you're using the correct Python version

See [BUILD_FIXES.md](docs/BUILD_FIXES.md) for information about current build issues and their workarounds.

## Roadmap

This section outlines planned improvements for the repository, with a focus on enhancing the template_fastapi_app to follow industry best practices.

### Planned Improvements for template_fastapi_app

#### Testing and Quality Assurance (Priority: High)
- [x] Add code coverage reporting with pytest-cov
- [x] Implement property-based testing with Hypothesis
- [x] Set up API contract testing
- [x] Add load testing configuration (k6 or Locust)
- [x] Implement mutation testing
- [x] Add end-to-end testing framework

#### Documentation Enhancements (Priority: Medium)
- [ ] Add Architectural Decision Records (ADRs)
- [ ] Document API versioning strategy
- [ ] Add generated data model documentation
- [ ] Implement automated API changelog
- [ ] Expand developer guides

#### Code Quality and Maintainability (Priority: High)
- [x] Configure stricter type checking with mypy
- [x] Integrate comprehensive linting (ruff/black/isort)
- [x] Set up pre-commit hooks
- [x] Add dependency scanning for security vulnerabilities
- [x] Implement complexity analysis

#### Security Enhancements (Priority: High)
- [x] Add secret rotation mechanism
- [ ] Implement API rate limiting
- [ ] Configure security headers
- [ ] Set up automated security scanning
- [ ] Implement Content Security Policy
- [ ] Add OAuth2 scope validation

#### Performance Optimizations (Priority: Medium)
- [ ] Add response compression
- [ ] Implement query optimization tools
- [ ] Set up caching layer
- [ ] Add async background tasks
- [ ] Optimize DB connection pooling

#### DevOps and Deployment Improvements (Priority: Medium)
- [ ] Enhance multi-environment configuration
- [ ] Add feature flag system
- [ ] Support canary deployments
- [ ] Implement database migration CI checks
- [ ] Document backup and restore procedures
- [ ] Convert to Helm charts

#### Monitoring and Observability (Priority: High)
- [ ] Add custom Prometheus metrics
- [ ] Implement structured logging
- [ ] Enhance health check endpoints
- [ ] Set up user behavior analytics
- [ ] Integrate with APM tools
- [ ] Add error tracking

#### Developer Experience (Priority: Medium)
- [ ] Add VS Code devcontainer
- [ ] Set up API client generation
- [ ] Create local development dashboard
- [ ] Improve database seeding scripts
- [ ] Add development utilities CLI
- [ ] Enhance hot reload for local development

#### Scalability Features (Priority: Low)
- [ ] Implement worker pattern for async tasks
- [ ] Add message queue integration
- [ ] Document database sharding strategy
- [ ] Support database read replicas
- [ ] Add horizontal scaling guidelines

#### Business Logic Organization (Priority: Medium)
- [ ] Reorganize code with domain-driven design patterns
- [ ] Implement CQRS for complex domains
- [ ] Add event sourcing capabilities
- [ ] Improve separation of business logic
- [ ] Create well-defined service layer

### Implementation Timeline

- **Q2 2024**: Testing and Quality Assurance, Code Quality
- **Q3 2024**: Security Enhancements, Monitoring and Observability
- **Q4 2024**: Documentation, Developer Experience, Business Logic
- **Q1 2025**: Performance Optimizations, DevOps, Scalability

## Contributing

We welcome contributions from the community! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

For more details, see our [Contribution Guide](CONTRIBUTING.md).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details. 