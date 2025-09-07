# Bazel Files

This directory contains Bazel configuration files and utilities for the monorepo.

## Purpose

The `projects/bazel/files` directory serves as a central location for:

- **Shared Bazel configurations**: Common build settings and rules
- **Custom build tools**: Bazel macros and custom rules
- **Build utilities**: Helper scripts and configuration files
- **Cross-language build support**: Configurations that support multiple languages

## Contents

Currently, this directory contains Bazel-related configuration files that support the monorepo's build infrastructure.

## Usage

These files are typically used as dependencies in other projects' `BUILD.bazel` files:

```python
# Example usage in other BUILD.bazel files
load("//projects/bazel/files:custom_rules.bzl", "my_custom_rule")

my_custom_rule(
    name = "example",
    # ... other attributes
)
```

## Integration with Monorepo

This directory is part of the overall Bazel build system that supports:

- **Python projects**: Various CLI and web applications
- **Java projects**: From simple console apps to Spring Boot services  
- **Go projects**: Web services and CLI tools
- **Template projects**: Code generators for new projects

## Contributing

When adding new Bazel utilities:

1. Place reusable build rules and macros here
2. Document their usage in this README
3. Add appropriate visibility declarations
4. Test integration with existing projects

## Build System Architecture

The monorepo uses Bazel 8.3.1 with:
- Rules for Python, Java, and Go
- Container image building with rules_oci
- Dependency management via Bazel modules
- Remote build caching with BuildBuddy

For more information about the overall build system, see the main repository README.