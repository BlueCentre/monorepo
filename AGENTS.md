# Project Overview

This is a monorepo designed to develop and showcase monorepo patterns and provide blueprints for rapid application development across multiple programming languages. It emphasizes efficient, hermetic, and repeatable builds using Bazel, and facilitates continuous development and integration workflows.

**Key Technologies:**

*   **Build System:** Bazel (primary build tool, managing dependencies via `MODULE.bazel` and `WORKSPACE.bzlmod`).
*   **Languages:** Supports Python, Java (Spring Boot), and Go applications.
*   **Continuous Development:** Skaffold for local development and deployment to Kubernetes.
*   **Continuous Integration:** CircleCI for automated builds and tests, leveraging Bazel and BuildBuddy for remote execution/caching.
*   **Infrastructure as Code (IaC):** Includes configurations for Terraform and Pulumi.

# Building and Running

This project primarily uses Bazel for building and testing, and Skaffold for local continuous development.

## Prerequisites

*   Bazelisk (as `bazel`)
*   Skaffold
*   Minikube (for local Kubernetes development)

## Getting Started

1.  **Clone the repository.**
2.  **Run the quickstart script:**
    ```bash
    make quickstart
    ```
    This command is expected to set up the local environment.
3.  **Initialize Minikube's Docker environment:**
    ```bash
    eval $(minikube -p minikube docker-env)
    ```

## Building with Bazel

To build all targets in the monorepo:

```bash
bazel build //...
```

To run all tests:

```bash
bazel test //...
```

For specific Java projects, the Java language and runtime versions are configured to use Java 11.

## Local Development with Skaffold

Skaffold is configured for continuous development, automatically building and deploying changes to a local Kubernetes cluster. Refer to the `skaffold.yaml` file for specific configurations, which include `pulumi_dev_local` and `projects/template/template_fastapi_app`.

# Development Conventions

*   **Bazel-centric Builds:** All projects within the monorepo are built and tested using Bazel, ensuring consistency and efficiency.
*   **Dependency Management:** External dependencies are managed through Bazel's Bzlmod (`MODULE.bazel`) and legacy `WORKSPACE.bzlmod` for backward compatibility.
*   **Polyglot Support:** The monorepo is designed to accommodate multiple programming languages, with specific rules and toolchains configured for Python (supporting multiple versions) and Java.
*   **Containerization:** Projects are set up to be containerized, with `pkg_tar` rules used for creating application archives, indicating a path towards Docker image creation.
*   **CI/CD Integration:** CircleCI pipelines are configured to automatically build and test changes using Bazel, integrating with BuildBuddy for remote execution and caching to speed up CI workflows.
