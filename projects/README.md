# Overview

This directory contains all projects and applications implemented within the monorepo. Projects are organized by language, template type, and purpose.

## Directory Convention

```
projects/
├── base/                      # Base components and utilities
├── bazel/                     # Bazel-specific project examples
├── go/                        # Go language projects
│   └── devops_go_app/         # Simple Go application example
├── java/                      # Java language projects
│   ├── simple_java_app/       # Basic Java application
│   └── java_web_server/       # Simple HTTP server in Java
├── py/                        # Python language projects
│   ├── calculator_cli_py_app/ # CLI calculator utility
│   ├── calculator_flask_app/  # Flask calculator web app
│   ├── devops_fastapi_app/    # FastAPI app with DevOps features
│   ├── echo_fastapi_app/      # Simple FastAPI application
│   └── helloworld_py_app/     # Basic Python application
├── template/                  # Project templates for new applications
│   ├── template_fastapi_app/  # FastAPI application template with PostgreSQL and Istio
│   ├── template_gin_app/      # Gin (Go) application template
│   └── template_typer_app/    # Typer CLI application template
├── microservices-demo/        # Microservices demonstration projects
└── opentelemetry-demo/        # OpenTelemetry demonstration projects
```

Each project typically contains:
- `BUILD.bazel` - Bazel build configuration
- `Dockerfile` or `Dockerfile.bazel` - Container image definition
- `kubernetes/` - Kubernetes manifests for deployment
- `skaffold.yaml` - Skaffold configuration for development and deployment
- `README.md` - Project-specific documentation
- Source code organized by language conventions

## Project Templates

The `template/` directory contains production-ready templates that can be used as starting points for new applications. These templates demonstrate best practices and include configuration for building, testing, and deploying applications within the monorepo.

### Using Templates

To use a template as a starting point for a new project:

1. Copy the template directory to the appropriate category directory
2. Rename the directory to match your new project name
3. Update the `BUILD.bazel` file to reference your new project name
4. Update the `skaffold.yaml` file with your new project name
5. Customize the application code and configurations as needed

For example:
```bash
# Create a new FastAPI application
cp -r projects/template/template_fastapi_app projects/py/my_new_fastapi_app
cd projects/py/my_new_fastapi_app
# Update project-specific files...
```

## Project Reference Table

| Project Name | Short Description | Upstream | State | CODEOWNER |
|--------------|-------------------|----------|-------|-----------|
| template_fastapi_app | FastAPI application template with PostgreSQL, JWT auth, Istio rate limiting | `None` | Production | [James Nguyen](mailto://james.nguyen@example.com) |
| template_gin_app | Gin (Go) application template | `None` | Production | [James Nguyen](mailto://james.nguyen@example.com) |
| template_typer_app | Typer CLI application template | `None` | Production | [James Nguyen](mailto://james.nguyen@example.com) |
| base_fastapi_app | Base project to extend | `None` | Production | [James Nguyen](mailto://james.nguyen@example.com) |
| devops_go_app | Simple Golang example | `Standalone` | Production | [James Nguyen](mailto://james.nguyen@example.com) |
| devops_fastapi_app | DevOps example FastAPI | `base_fastapi_app` | Development | [James Nguyen](mailto://james.nguyen@example.com) |
| echo_fastapi_app | Simple echo example FastAPI | `Standalone` | Development | [James Nguyen](mailto://james.nguyen@example.com) |
| helloworld_py_app | Simple helloworld python container example | `Standalone` | Production | [James Nguyen](mailto://james.nguyen@example.com) |
| calculator_cli_py_app | CLI calculator utility | `Standalone` | Production | [James Nguyen](mailto://james.nguyen@example.com) |
| calculator_flask_app | Flask calculator web app | `Standalone` | Production | [James Nguyen](mailto://james.nguyen@example.com) |
| microservices-demo | Microservices demonstration projects | `Standalone` | Development | [James Nguyen](mailto://james.nguyen@example.com) |
| opentelemetry-demo | OpenTelemetry demonstration projects | `Standalone` | Development | [James Nguyen](mailto://james.nguyen@example.com) |
