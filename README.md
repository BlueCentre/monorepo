# Monorepo Project

[![CI](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml/badge.svg)](https://github.com/BlueCentre/monorepo/actions/workflows/ci.yml)
[![Documentation Status](https://img.shields.io/badge/docs-up--to--date-brightgreen)](https://github.com/BlueCentre/monorepo/wiki)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

## Overview

A monorepo built with Bazel that supports multiple languages and frameworks. Uses Skaffold for consistent local and CI/CD development workflows. Contains reusable components, templates, and production applications.

### Key Features

- **Unified Build System**: Consistent builds using Bazel across all projects
- **Cross-Language Support**: Projects in Python, Java, and more
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
- Infrastructure as code is supported through both:
  - Terraform (HCL) in `terraform_dev_local/`
  - Pulumi (Go) in `pulumi_dev_local/`
- Each technology stack maintains feature parity to provide flexibility in infrastructure management

```
monorepo/
├── projects/                 # All projects organized by category
│   ├── base/                 # Base project templates and utilities
│   │   └── base_fastapi_app/ # Base FastAPI project to extend
│   ├── bazel/                # Bazel-specific project examples
│   ├── go/                   # Go language projects
│   │   └── devops_go_app/    # Simple Go application example
│   ├── java/                 # Java applications and libraries
│   │   ├── simple_java_app/  # Basic Java application
│   │   ├── example1_java_app/# Java example application 1
│   │   ├── example2_java_app/# Java example application 2
│   │   ├── hello_springboot_app/ # Spring Boot hello world application
│   │   └── rs_springboot_app/    # Spring Boot RESTful service application
│   ├── py/                   # Python applications and libraries
│   │   ├── calculator_cli_py_app/  # CLI calculator utility
│   │   ├── calculator_flask_app/   # Flask calculator web app
│   │   ├── devops_fastapi_app/     # FastAPI app with DevOps features
│   │   ├── echo_fastapi_app/       # Simple FastAPI application
│   │   └── helloworld_py_app/      # Basic Python application
│   ├── template/             # Project templates
│   │   ├── template_fastapi_app/    # FastAPI application template with PostgreSQL and Istio
│   │   ├── template_gin_app/        # Gin (Go) application template
│   │   └── template_typer_app/      # Typer CLI application template
│   ├── microservices-demo/   # Microservices demonstration projects
│   └── opentelemetry-demo/   # OpenTelemetry demonstration projects
├── libs/                     # Shared libraries and utilities
├── third_party/              # Third-party dependencies
├── tools/                    # Development and build tools
├── docs/                     # Documentation files
├── terraform_dev_local/      # Terraform configurations for local development
├── pulumi_dev_local/         # Pulumi configurations for local development
├── terraform_lab_gcp/        # Terraform configurations for GCP
├── .bazelignore              # Files and directories to ignore in Bazel builds
├── .bazelrc                  # Bazel configuration
├── BUILD.bazel               # Root BUILD file
├── MODULE.bazel              # Bazel module definition
├── WORKSPACE                 # Bazel workspace definition (legacy)
├── quick-start-guide.md      # Quick start guide for new users
├── README-rate-limiting.md   # Documentation for Istio rate limiting
└── skaffold.yaml             # Root Skaffold configuration
```

## Project Catalog

| Project | Description | Technologies | Status |
|---------|-------------|--------------|--------|
| [template_fastapi_app](./projects/template/template_fastapi_app) | FastAPI application template with PostgreSQL, JWT auth, Istio rate limiting, and OpenTelemetry | Python, FastAPI, PostgreSQL, K8s, Istio | ✅ Active |
| [terraform_dev_local](./terraform_dev_local) | Local development environment with essential K8s components | Terraform, Kubernetes, Helm | ✅ Active |
| [pulumi_dev_local](./pulumi_dev_local) | Local development environment with essential K8s components (YAML) | Pulumi, Kubernetes, Helm | ✅ Active |
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

The [FastAPI Template App](./projects/template/template_fastapi_app) provides a production-ready template for building robust API services with FastAPI and PostgreSQL. It includes:

### Key Features

- **Complete API Structure**: Well-organized project structure following best practices
- **Authentication**: JWT-based authentication with OAuth2 password flow
- **Database Integration**: PostgreSQL with SQLAlchemy ORM and Alembic migrations
- **Kubernetes Deployment**: Ready-to-use Kubernetes manifests with Skaffold
- **OpenTelemetry**: Integrated observability for distributed tracing
- **API Documentation**: Automatic documentation with Swagger UI and ReDoc
- **Istio Integration**: Service mesh features including rate limiting
- **Key Management**: Automatic and manual JWT key rotation for enhanced security
- **Rate Limiting**: Both application and infrastructure-level rate limiting
- **Notes API**: Full-featured notes management with CRUD operations
- **Items API**: Example API for managing items with owner relationships
- **Seed Data Utilities**: Tools for generating test data for development and demos

### Recent Improvements

- Added Istio-based rate limiting with comprehensive configuration
- Added automatic JWT key rotation for enhanced security
- Enhanced database connection handling for Kubernetes environments
- Added comprehensive verification and smoke tests for deployments
- Updated documentation for rate limiting and Istio integration

### Getting Started

```bash
# Navigate to the project
cd projects/template/template_fastapi_app

# Deploy to Kubernetes (standard mode)
skaffold run -m template-fastapi-app -p dev

# OR deploy with Istio rate limiting
skaffold run -m template-fastapi-app -p istio-rate-limit

# Set up port forwarding
kubectl port-forward service/template-fastapi-app -n template-fastapi-app 8000:80
```

Access the API documentation at http://localhost:8000/docs

## Local Development Environment Options

We provide two options for setting up your local development environment with essential Kubernetes components:

### Terraform-based Local Development Environment

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Colima](https://img.shields.io/badge/colima-local_k8s-blue?style=for-the-badge)

The [terraform_dev_local](./terraform_dev_local) directory provides a powerful toolkit for setting up a local Kubernetes development environment with essential components for containerized application development.

#### Key Components

- **Cert Manager** (v1.17.0): Automated SSL certificate management.
- **External Secrets** (v0.14.4): Integration with external secret management systems.
- **External DNS** (v1.15.0): Automated DNS configuration.
- **OpenTelemetry** (v0.79.0): Comprehensive observability stack.
- **Istio** (v1.23.3): Full-featured service mesh for microservices.
- **Argo CD** (v7.8.2): GitOps continuous delivery.
- **Telepresence**: Seamless local development with remote clusters.

#### Quick Start

```bash
# Navigate to the directory
cd terraform_dev_local

# Initialize Terraform
terraform init

# Configure components in terraform.auto.tfvars
# Apply the configuration
terraform apply
```

For more details, see the [terraform_dev_local README](./terraform_dev_local/README.md).

### Pulumi YAML-based Local Development Environment

![Pulumi](https://img.shields.io/badge/pulumi-%235C4EE5.svg?style=for-the-badge&logo=pulumi&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Colima](https://img.shields.io/badge/colima-local_k8s-blue?style=for-the-badge)

The [pulumi_dev_local](./pulumi_dev_local) directory provides an alternative implementation using Pulumi's YAML language for the same functionality as the Terraform version.

#### Key Features

- **YAML-Based**: Uses Pulumi's YAML language for improved readability
- **Component Parity**: Same functionality as the Terraform version
- **Simplified Configuration**: Easy-to-understand configuration files
- **Modern IaC**: Uses Pulumi's latest features for infrastructure management

#### Key Components

- **Cert Manager** (v1.17.0): Automated SSL certificate management
- **External Secrets** (v0.14.4): Integration with external secret management systems
- **External DNS** (v1.15.0): Automated DNS configuration
- **OpenTelemetry Stack** (v0.79.0): Complete observability solution with Operator and Collector
- **Istio** (v1.23.3): Full-featured service mesh with Base, CNI, Control Plane (istiod), and Ingress Gateway
- **Argo CD** (v7.8.2): GitOps continuous delivery tool

#### Quick Start

```bash
# Navigate to the directory
cd pulumi_dev_local

# Initialize Pulumi
pulumi login --local
pulumi stack init dev

# Set a passphrase for configuration encryption
export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"

# Preview the deployment
pulumi preview

# Deploy the components
pulumi up
```

For more details, see the [pulumi_dev_local README](./pulumi_dev_local/README.md).

## Managing Infrastructure Components

This monorepo provides two options for managing your local Kubernetes infrastructure components: Terraform and Pulumi. You can choose either based on your preference or team requirements. Both configurations support the same set of components that can be enabled or disabled based on your needs.

### Available Components

The following components can be enabled or disabled in both Terraform and Pulumi configurations:

| Component | Description | Terraform Version | Pulumi Version |
|-----------|-------------|------------------|----------------|
| cert-manager | Automates certificate management | v1.17.0 | v1.17.0 |
| external-secrets | Manages external secrets (e.g., from cloud providers) | v0.14.4 | v0.14.4 |
| external-dns | Synchronizes Kubernetes Ingress with DNS providers | v1.15.0 | v1.15.0 |
| opentelemetry | Provides telemetry and observability | v0.79.0 | v0.79.0 |
| datadog | Monitoring and observability platform | - | - |
| telepresence | Local development tool for Kubernetes microservices | - | - |
| istio | Service mesh for traffic management, security, and observability | v1.23.3 | v1.23.3 |
| argocd | GitOps continuous delivery tool | v7.8.2 | v7.8.2 |

### Enabling/Disabling Components in Terraform

1. Navigate to the `terraform_dev_local` directory:
   ```bash
   cd terraform_dev_local
   ```

2. Edit the `terraform.auto.tfvars` file to enable or disable components:
   ```terraform
   # Enable components by setting them to true
   cert_manager_enabled = true
   external_secrets_enabled = true 
   
   # Disable components by setting them to false or by commenting the line
   # external_dns_enabled = true
   ```

3. For some components, you may need to rename the corresponding `.tf.inactive` file:
   ```bash
   # To enable a component that has an inactive file
   cp helm_external_secrets.tf.inactive helm_external_secrets.tf
   
   # To disable a component that's currently active
   mv helm_external_secrets.tf helm_external_secrets.tf.inactive
   ```

4. Apply the changes:
   ```bash
   terraform apply
   ```

### Enabling/Disabling Components in Pulumi

1. Navigate to the `pulumi_dev_local` directory:
   ```bash
   cd pulumi_dev_local
   ```

2. Enable or disable components by updating the `Pulumi.dev.yaml` configuration:
   ```yaml
   config:
     pulumi-dev-local:certManagerEnabled: "true"
     pulumi-dev-local:external_secrets_enabled: "true"
     pulumi-dev-local:external_dns_enabled: "false"
   ```

3. Alternatively, you can modify the defaults in `main.yaml`:
   ```yaml
   variables:
     certManagerEnabled:
       type: boolean
       default: true
     externalSecretsEnabled:
       type: boolean
       default: true
   ```

4. Apply the changes:
   ```bash
   pulumi up
   ```

### Example: Enabling External Secrets

#### In Terraform:
1. Set `external_secrets_enabled = true` in `terraform_dev_local/terraform.auto.tfvars`
2. Ensure `helm_external_secrets.tf` exists (rename from `.tf.inactive` if needed)
3. Run `terraform apply`

#### In Pulumi:
1. Set `pulumi-dev-local:external_secrets_enabled: "true"` in `pulumi_dev_local/Pulumi.dev.yaml`
2. Ensure `externalSecretsEnabled` is set to `true` in `pulumi_dev_local/main.yaml`
3. Run `pulumi up`

Using these steps, you can customize your local Kubernetes environment by enabling only the components you need for your specific use case.

## Quick Start Guides

We provide several quick start guides to help you get started with different aspects of the repository:

- [Quick Start Guide for Istio Rate Limiting](quick-start-guide.md) - Step-by-step guide to setting up and testing rate limiting with Istio
- [Istio Rate Limiting Documentation](README-rate-limiting.md) - Detailed documentation on the rate limiting implementation
- [Template FastAPI App Documentation](./projects/template/template_fastapi_app/README.md) - Comprehensive guide to the FastAPI template application
- [Skaffold Usage Guide](./projects/template/template_fastapi_app/SKAFFOLD-USAGE.md) - Detailed guide on using Skaffold with the FastAPI template
- [Istio Setup Guide](./projects/template/template_fastapi_app/ISTIO-SETUP.md) - Guide for setting up Istio with the FastAPI template
- [Istio Troubleshooting Guide](./projects/template/template_fastapi_app/ISTIO-TROUBLESHOOTING.md) - Solutions for common Istio integration issues

## Getting Started

### Prerequisites

- [Bazel](https://bazel.build/install) (or [Bazelisk](https://github.com/bazelbuild/bazelisk) for automatic version management)
- Java JDK 11+
- Python 3.9+
- Docker (for containerized applications)
- [Colima](https://github.com/abiosoft/colima) (for local Kubernetes)
- [Skaffold](https://skaffold.dev/docs/install/) (for Kubernetes deployment)
- [Istio](https://istio.io/latest/docs/setup/getting-started/) (optional, for service mesh features)

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
# Python FastAPI template project
cd projects/template/template_fastapi_app
skaffold dev -m template-fastapi-app  # Start the development environment

# Python CLI app
bazel run //projects/py/calculator_cli_py_app

# Deploy with Istio rate limiting
skaffold run -m template-fastapi-app -p istio-rate-limit
```

## Development Workflow

The recommended development workflow uses Skaffold for Kubernetes-based projects and Bazel for direct builds.

### Development with Skaffold

Skaffold is our recommended tool for developing and deploying Kubernetes applications. It provides a seamless development experience with live reload capabilities.

#### Basic Skaffold Commands

```bash
# Build project artifacts
skaffold build -m <project-name>

# Test project
skaffold test -m <project-name>

# Deploy project
skaffold run -m <project-name> -p <profile-name>

# Development mode with live reload
skaffold dev -m <project-name> -p <profile-name>

# Verify deployment
skaffold verify -m <project-name>

# Execute custom actions
skaffold exec <action-name> -m <profile-name>
```

#### Example: FastAPI Template App Development

```bash
# Clone and set up
git clone https://github.com/BlueCentre/monorepo.git
cd monorepo
git checkout -b feature/enhanced-api

# Navigate to the FastAPI project
cd projects/template/template_fastapi_app

# Start development mode
skaffold dev -m template-fastapi-app -p dev

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

### Development with Bazel

For non-containerized applications or when working on shared libraries, use Bazel directly:

```bash
# Build a specific target
bazel build //path/to/target

# Run tests for a specific target
bazel test //path/to/target

# Run an application
bazel run //path/to/application
```

### Validation Practices

Always validate code and configuration changes:

1. Build the project: `bazel build //...`
2. Run tests: `bazel test //...`
3. Deploy with Skaffold: `skaffold run -m <project-name> -p dev`
4. Verify the deployment: `skaffold verify -m <project-name>`

### Branch Naming Conventions

- Feature branches: `feature/name-of-feature`
- Bug fixes: `fix/issue-description`
- Documentation updates: `docs/what-was-updated`
- Release branches: `release/version-number`

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
bazel run //projects/py/calculator_cli_py_app

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
- [x] Implement API rate limiting
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

#### Infrastructure Improvements for pulumi_dev_local (Priority: Medium)
- [ ] Implement Skaffold integration with dedicated profiles for Pulumi operations
- [ ] Add custom Skaffold actions for infrastructure lifecycle management
- [ ] Create templated infrastructure configurations for common development scenarios
- [ ] Develop a simplified CLI wrapper for common Pulumi operations
- [ ] Implement infrastructure testing and validation hooks
- [ ] Create comprehensive documentation similar to SKAFFOLD-USAGE.md
- [ ] Add resource caching mechanisms to improve deployment speeds
- [ ] Implement monitoring and observability for provisioned resources
- [ ] Ensure Pulumi stacks align with Skaffold profiles for consistent environments
- [ ] Add shared component libraries for common infrastructure patterns

### Implementation Timeline

- **Q2 2024**: Testing and Quality Assurance, Code Quality
- **Q3 2024**: Security Enhancements, Monitoring and Observability, Infrastructure Improvements for pulumi_dev_local
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
