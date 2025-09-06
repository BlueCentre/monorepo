# Monorepo Project

[![CI](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml/badge.svg)](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml)
[![Python Dependency Drift](https://github.com/BlueCentre/monorepo/actions/workflows/python-deps-drift.yml/badge.svg)](https://github.com/BlueCentre/monorepo/actions/workflows/python-deps-drift.yml)
[![Documentation Status](https://img.shields.io/badge/docs-up--to--date-brightgreen)](https://github.com/BlueCentre/monorepo/wiki)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

## Overview

A monorepo built with Bazel that supports multiple languages and frameworks. Uses Skaffold for consistent local and CI/CD development workflows. Contains reusable components, templates, and production applications.

### Key Features

- **Unified Build System**: Consistent builds using Bazel across all projects
- **Cross-Language Support**: Projects in Python, Java, Go, and more
- **Standardized Templates**: Common project templates for quick bootstrapping
- **Integrated Testing**: Streamlined testing infrastructure
- **Shared Libraries**: Common code shared across projects
- **CI/CD Integration**: GitHub Actions workflows for continuous integration
- **Service Mesh Integration**: Istio-based rate limiting and traffic management
- **Kubernetes Orchestration**: Skaffold-based development and deployment workflows
- **Infrastructure as Code**: Terraform or Pulumi options to manage essential Kubernetes components

## Repository Structure

This monorepo contains multiple projects with different technologies:

- All projects are located in the `projects/` directory
- Infrastructure as Code (IaC) is supported through both:
  - Terraform (HCL) in `terraform_dev_local/`
  - Pulumi (Go) in `pulumi_dev_local/`
- Each technology stack maintains feature parity to provide flexibility and options for infrastructure management to support local containerized application development

```text
monorepo/
├── projects/                   # All projects organized by category
│   ├── base/                   # Base project templates and utilities
│   │   └── base_fastapi_app/   # Base FastAPI project to extend
│   ├── bazel/                  # Bazel-specific project examples
│   ├── go/                     # Go language projects
│   │   └── devops_go_app/      # Simple Go application example
│   ├── java/                   # Java applications and libraries
│   │   ├── simple_java_app/    # Basic Java application
│   │   ├── example1_java_app/  # Java example application 1
│   │   ├── example2_java_app/  # Java example application 2
│   │   ├── hello_springboot_app/  # Spring Boot hello world application
│   │   └── rs_springboot_app/     # Spring Boot RESTful service application
│   ├── py/                     # Python applications and libraries
│   │   ├── calculator_cli_py_app/  # CLI calculator utility
│   │   ├── calculator_flask_app/   # Flask calculator web app
│   │   ├── devops_fastapi_app/     # FastAPI app with DevOps features
│   │   ├── echo_fastapi_app/       # Simple FastAPI application
│   │   └── helloworld_py_app/      # Basic Python application
│   ├── template/               # Project templates
│   │   ├── template_fastapi_app/    # FastAPI application template with PostgreSQL and Istio
│   │   ├── template_gin_app/        # Gin (Go) application template
│   │   └── template_typer_app/      # Typer CLI application template
│   ├── microservices-demo/     # Microservices demonstration projects
│   └── opentelemetry-demo/     # OpenTelemetry demonstration projects
├── libs/                       # Shared libraries and utilities
├── third_party/                # Third-party dependencies
├── tools/                      # Development and build tools
├── docs/                       # Documentation files and guides
│   ├── infrastructure-comparison.md  # Terraform vs Pulumi implementation analysis
│   ├── quick-start-guide.md          # Quick start guide for new users
│   ├── rate-limiting.md              # Documentation for Istio rate limiting
│   └── contributing/                  # Contribution guidelines
├── terraform_dev_local/        # Terraform configurations for local development
├── pulumi_dev_local/           # Pulumi configurations for local development
├── terraform_lab_gcp/          # Terraform configurations for GCP
├── .bazelignore                # Files and directories to ignore in Bazel builds
├── .bazelrc                    # Bazel configuration
├── BUILD.bazel                 # Root BUILD file
├── MODULE.bazel                # Bazel module definition
├── WORKSPACE                   # Bazel workspace definition (legacy)
└── skaffold.yaml               # Root Skaffold configuration
```

## Project Catalog

| Project | Description | Technologies | Status |
|---------|-------------|--------------|--------|
| [template_fastapi_app](./projects/template/template_fastapi_app) | FastAPI application template with PostgreSQL, JWT auth, Istio rate limiting, and OpenTelemetry | Python, FastAPI, PostgreSQL, K8s, Istio | ✅ Active |
| [terraform_dev_local](./terraform_dev_local) | Local development environment with essential K8s components | Terraform, Kubernetes, Helm | ✅ Active |
| [pulumi_dev_local](./pulumi_dev_local) | Local development environment with essential K8s components | Pulumi, Kubernetes, Helm | ✅ Active |
| [echo_fastapi_app](./projects/py/echo_fastapi_app) | Simple FastAPI application | Python, FastAPI | ✅ Active |
| [calculator_cli_py_app](./projects/py/calculator_cli_py_app) | Command-line calculator utility | Python | ✅ Active |
| [devops_fastapi_app](./projects/py/devops_fastapi_app) | FastAPI application with DevOps features | Python, FastAPI | ✅ Active |
| [calculator_flask_app](./projects/py/calculator_flask_app) | Flask-based calculator web application | Python, Flask | ✅ Active |
| [helloworld_py_app](./projects/py/helloworld_py_app) | Basic Python application | Python | ✅ Active |
| [template_gin_app](./projects/template/template_gin_app) | Gin application template | Go, Gin | ✅ Active |
| [template_typer_app](./projects/template/template_typer_app) | Typer CLI application template | Python, Typer | ✅ Active |
| [simple_java_app](./projects/java/simple_java_app) | Basic Java application | Java | ✅ Active |
| [hello_springboot_app](./projects/java/hello_springboot_app) | Spring Boot hello world application | Java, Spring Boot | ✅ Active |
| [rs_springboot_app](./projects/java/rs_springboot_app) | Spring Boot RESTful service application | Java, Spring Boot, REST | ✅ Active |
| [base_fastapi_app](./projects/base/base_fastapi_app) | Base FastAPI project to extend | Python, FastAPI | ✅ Active |
| [devops_go_app](./projects/go/devops_go_app) | Simple Go application example | Go | ✅ Active |
| [microservices-demo](./projects/microservices-demo) | Microservices demonstration projects | Various | ✅ Active |
| [opentelemetry-demo](./projects/opentelemetry-demo) | OpenTelemetry demonstration projects | Various | ✅ Active |

## Featured Project: FastAPI Template App

![FastAPI](https://img.shields.io/badge/FastAPI-0.103.1-009688.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791.svg)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5.svg)
![Istio](https://img.shields.io/badge/Istio-Rate%20Limiting-466BB0.svg)

The [FastAPI Template App](./projects/template/template_fastapi_app) provides a production-ready starting point for building robust API services. It integrates FastAPI, PostgreSQL, JWT authentication, Alembic migrations, Kubernetes deployment via Skaffold, OpenTelemetry, and Istio rate limiting.

**For full details, features, and getting started instructions, please see the [FastAPI Template App README](./projects/template/template_fastapi_app/README.md).**

## Local Development Environment Options

This repository offers two parallel implementations for provisioning a local Kubernetes development environment populated with essential infrastructure components (like service mesh, cert management, observability, etc.). Both options provide feature parity.

### Terraform-based Local Development Environment

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

Located in the [`terraform_dev_local`](./terraform_dev_local) directory, this option uses Terraform (HCL) to manage Kubernetes components via Helm charts.

**For setup instructions, component details, and usage guidance, refer to the [Terraform Local Dev README](./terraform_dev_local/README.md).**

### Pulumi-based Local Development Environment

![Pulumi](https://img.shields.io/badge/pulumi-%235C4EE5.svg?style=for-the-badge&logo=pulumi&logoColor=white)

Located in the [`pulumi_dev_local`](./pulumi_dev_local) directory, this option uses Pulumi (Go) to manage the same set of Kubernetes components via Helm charts.

**For setup instructions, component details, and usage guidance, refer to the [Pulumi Local Dev README](./pulumi_dev_local/README.md).**

## Managing Infrastructure Components

The specific components available (like Istio, Cert Manager, Argo CD, OpenTelemetry, etc.) and their configuration details are documented within each respective local development environment directory:

- **Terraform Components:** [`terraform_dev_local/docs/COMPONENTS.md`](./terraform_dev_local/docs/COMPONENTS.md)
- **Pulumi Components:** [`pulumi_dev_local/docs/COMPONENTS.md`](./pulumi_dev_local/docs/COMPONENTS.md)

Both implementations strive to maintain feature and version parity for these components.

For guidance on contributing new or complex infrastructure components applicable to both Terraform and Pulumi, please refer to:

- **[Infrastructure Comparison: Terraform vs Pulumi](./docs/infrastructure-comparison.md)** - Comprehensive analysis of our implementations
- **[Contributing Complex IAC Components](./docs/contributing/iac-components.md)** - Guidelines for adding new components

## Getting Started (Application Development)

See the **[Quick Start Guide](./docs/quick-start-guide.md)** for end-to-end environment setup and workflow details. Below is a concise orientation:

1. Install: Bazel, Skaffold, Docker (optionally Colima for local k8s)
1. Provision infra (optional): choose either [Terraform local dev](./terraform_dev_local/README.md) or [Pulumi local dev](./pulumi_dev_local/README.md)
1. Generate a project (service, CLI, etc.): see **[Project Generation](./docs/project-generation.md)**
1. Manage dependencies & drift: see **[Dependency Management](./docs/dependency-management.md)**
1. Develop & iterate: use Skaffold profiles (`skaffold dev -m <module> -p dev`)
1. Validate: run Bazel builds/tests and any template-specific docs

Common Skaffold workflow:

```bash
skaffold build     # Build images
skaffold run       # Deploy once
skaffold dev -m template-fastapi-app -p dev  # Iterative dev
skaffold test      # Run tests
skaffold verify    # Smoke/verification
skaffold delete    # Cleanup
```

## Quick Project Creation

For full template matrix, flags, and examples see **[Project Generation](./docs/project-generation.md)**.

Minimal examples:

```bash
# Interactive
bazel run //tools:new_project

# FastAPI service
bazel run //tools:new_project -- --language python --project-type fastapi --project-name my_service

# List templates
bazel run //tools:new_project -- --list-templates
```

### Dependency Management

Python dependency model, lock export process, and drift enforcement are documented in **[Dependency Management](./docs/dependency-management.md)**. See that doc for update workflow, enforcement layers (pre-commit, Bazel test, CI), and Copier pin alignment.

### Supported Languages and Project Types

| Language | Project Type | Status | Template Source | Description |
|----------|--------------|--------|-----------------|-------------|
| **Python** | FastAPI | ✅ Available | `template_fastapi_app` | Production-ready FastAPI web service with PostgreSQL, JWT auth, and Kubernetes deployment |
| **Python** | CLI | ✅ Available | `template_typer_app` | Command-line application using Typer framework |
| **Python** | Flask | 🚧 Placeholder | - | Web application using Flask framework |
| **Go** | Gin | ✅ Available | `template_gin_app` | Web service using Gin web framework |
| **Go** | CLI | 🚧 Placeholder | - | Command-line application in Go |
| **Java** | Spring Boot | 🚧 Placeholder | - | Web service using Spring Boot framework |

**Legend:**

- ✅ **Available**: Full template with complete project structure
- 🚧 **Placeholder**: Creates basic project structure; template coming soon

### Example Usage

```bash
# Interactive mode - prompts for all options
bazel run //tools:new_project

# Follow the prompts to select:
# 1. Language (python, go, java)
# 2. Project type (fastapi, cli, gin, springboot, etc.)
# 3. Project name (e.g., my_awesome_api)
```

The generator will:

1. Create a new project directory in `projects/{language}/{project_name}`
2. Copy the appropriate template (if available) or create a placeholder project
3. Customize the project with your chosen name and details
4. Provide next steps for development

## Documentation

For comprehensive documentation about this repository:

- **[Infrastructure Comparison](./docs/infrastructure-comparison.md)** - Analysis of our Terraform and Pulumi implementations
- **[Quick Start Guide](./docs/quick-start-guide.md)** - Getting started with this repository
- **[Rate Limiting Guide](./docs/rate-limiting.md)** - Documentation for Istio rate limiting
- **[Bazel Cheat Sheet](./docs/CHEATSHEET_BAZEL.md)** - Reference for common Bazel commands
- **[Container Guidelines](./docs/CONTAINER_README.md)** - Guidelines for working with containers
- **[Build Fixes](./docs/BUILD_FIXES.md)** - Solutions for common build issues

See the **[Documentation Index](./docs/README.md)** for a complete listing of available documentation.

## Contributing

Contributions are welcome! Please follow standard Git workflow (fork, branch, pull request). Ensure Bazel builds and tests pass. Update relevant documentation for any changes.

For contribution guidelines, please see:

- **[Contributing to Infrastructure Components](./docs/contributing/iac-components.md)**
- **[Contributing to Applications](./docs/contributing/application.md)**
- **[Contributing to Platform](./docs/contributing/platform.md)**

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
