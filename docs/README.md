# Documentation

This directory contains documentation for the monorepo, including development guides, infrastructure, design decisions, and component references.

## Core Documentation

- [Infrastructure Comparison: Terraform vs Pulumi](./infrastructure-comparison.md) - Comprehensive analysis of our Terraform and Pulumi implementations
- [Quick Start Guide](./quick-start-guide.md) - Getting started with this repository
- [Rate Limiting Guide](./rate-limiting.md) - How to use the Istio+Redis rate limiting capability
- [Dependency Management](./dependency-management.md) - Python uv-based lock, export, and drift enforcement
- [Project Generation](./project-generation.md) - Creating new projects via the Bazel Copier generator

## Contribution Guides

- [Contributing to Infrastructure Components](./CONTRIBUTING_COMPLEX_IAC_COMPONENTS.md) - Guidelines for adding new infrastructure components
- [Contributing to Applications](./contributing/application.md) - Guidelines for application development

## Detailed Reference Materials

### Infrastructure

- [Terraform Components](../terraform_dev_local/docs/COMPONENTS.md) - Reference for all Terraform-managed components
- [Pulumi Components](../pulumi_dev_local/docs/COMPONENTS.md) - Reference for all Pulumi-managed components

### Application Documentation

- **Template FastAPI Application**: Documentation has been moved to the [project directory](../projects/template/template_fastapi_app/docs/)
  - [Developer Quickstart](../projects/template/template_fastapi_app/docs/developer-quickstart.md)
  - [Architecture Overview](../projects/template/template_fastapi_app/docs/architecture-overview.md)
  - [Design Documentation](../projects/template/template_fastapi_app/docs/design-documentation.md)

### Development Tools

- [Bazel Cheat Sheet](./CHEATSHEET_BAZEL.md) - Quick reference for Bazel commands and patterns
- [Container Development](./CONTAINER_README.md) - Guidelines for working with containers

## Design Decisions

The [design_decisions/](./design_decisions/) directory contains documentation related to architectural choices and patterns used in this repository.

## User Guides

The [user_guides/](./user_guides/) directory contains step-by-step instructions for common tasks and workflows.

## Notes

- If you are just updating docs without touching any code, you may add any of the following to your [commit](https://docs.github.com/en/actions/managing-workflow-runs/skipping-workflow-runs) message to bypass CI
  - `[skip ci]`
  - `[ci skip]`
  - `[no ci]`
  - `[skip actions]`
  - `[actions skip]`
