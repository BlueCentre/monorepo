# Monorepo Project

[![CI](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml/badge.svg)](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml)
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

```
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
├── docs/                       # Documentation files (including CONTRIBUTING_COMPLEX_IAC_COMPONENTS.md)
├── terraform_dev_local/        # Terraform configurations for local development
├── pulumi_dev_local/           # Pulumi configurations for local development
├── terraform_lab_gcp/          # Terraform configurations for GCP
├── .bazelignore                # Files and directories to ignore in Bazel builds
├── .bazelrc                    # Bazel configuration
├── BUILD.bazel                 # Root BUILD file
├── MODULE.bazel                # Bazel module definition
├── WORKSPACE                   # Bazel workspace definition (legacy)
├── quick-start-guide.md        # Quick start guide for new users
├── README-rate-limiting.md     # Documentation for Istio rate limiting
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

- **[Contributing Complex IAC Components](./docs/CONTRIBUTING_COMPLEX_IAC_COMPONENTS.md)**

## Getting Started (Application Development)

To get started with developing applications within this monorepo:

1.  **Prerequisites**: Ensure you have [Bazel](https://bazel.build/), [Skaffold](https://skaffold.dev/), [Docker](https://www.docker.com/), and optionally [Colima](https://github.com/abiosoft/colima) (for local Kubernetes) installed.
2.  **Choose an Infrastructure Backend**: Set up either the [Terraform](./terraform_dev_local/README.md) or [Pulumi](./pulumi_dev_local/README.md) local development environment if your application requires Kubernetes infrastructure components (like databases, service mesh, etc.).
3.  **Explore Projects**: Browse the [`projects/`](./projects) directory and the [Project Catalog](#project-catalog) table.
4.  **Consult Project READMEs**: Each project directory (e.g., `projects/template/template_fastapi_app/`) contains a specific `README.md` with detailed build, test, and run instructions using Skaffold.
5.  **General Workflow**: Most projects follow a Skaffold-based workflow:
    *   `skaffold build`: Build container images.
    *   `skaffold run`: Deploy to Kubernetes.
    *   `skaffold dev`: Run in development mode with hot-reloading.
    *   `skaffold test`: Run tests.
    *   `skaffold verify`: Run smoke tests/verification checks.
    *   `skaffold delete`: Clean up deployed resources.

Refer to individual project READMEs and the `skaffold.yaml` files for specific profiles and modules (`-p <profile> -m <module>`).

## Contributing

Contributions are welcome! Please follow standard Git workflow (fork, branch, pull request). Ensure Bazel builds and tests pass. Update relevant documentation for any changes.

For infrastructure contributions, please see the [Contributing Complex IAC Components](./docs/CONTRIBUTING_COMPLEX_IAC_COMPONENTS.md) guide.

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
