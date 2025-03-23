# Monorepo - Rules for AI

This file provides guidance for working with monorepo structures in your projects.

## Project Structure

```
monorepo/
|-- README.md
|-- Makefile
|-- skaffold.yaml
|-- WORKSPACE.bazel
|-- MODULE.bazel
|-- BUILD.bazel
|-- .cursorrules
|-- bazel-*/**                    -> bazel local directories not checked in
|-- fixes/**                      -> bazel temporary fixes
|-- docs/**                       -> documentation
|-- libs/                         -> common used libraries
|   |-- BUILD.bazel
|   |-- README.md
|   |-- base/
|   |-- calculator/
|   |-- echo/
|   `-- ...
|-- projects/                     -> all projects created here
|   |-- BUILD.bazel
|   |-- README.md
|   |-- bazel/
|   |-- base_project/
|   |-- py_calculator_cli_app/
|   |-- py_calculator_flask_app/
|   |-- echo_fastapi_app/
|   |-- py_helloworld_cli_app/
|   |-- py_helloworld_v2_cli_app/
|   `-- ...
|-- third_party/                  -> 3rd party dependencies
|   |-- README.md
|   |-- python/
|   `-- ...
`-- tools/                        -> bazel specific tooling
    |-- README.md
    |-- pytest
    `-- workspace_status.sh
```

## General Guidelines

1. Organize code into logical modules and projects
2. Use a consistent build system across all projects (e.g., Bazel)
3. Share common code through libraries
4. Maintain clear boundaries between projects
5. Use consistent versioning and dependency management

## Implementation Details

- Use a single source of truth for dependencies
- Implement clear visibility rules between projects
- Leverage build system features for efficient builds
- Implement CI/CD pipelines that understand the monorepo structure

## Example .cursorrules File

```
// Monorepo - Rules for AI
// This file provides guidance for working with monorepo structures

// Project Structure
// - libs/: Common libraries shared across projects
// - projects/: Individual applications and services
// - third_party/: External dependencies
// - tools/: Build and development tools

// General Guidelines
// 1. Organize code into logical modules and projects
// 2. Use a consistent build system across all projects (e.g., Bazel)
// 3. Share common code through libraries
// 4. Maintain clear boundaries between projects
// 5. Use consistent versioning and dependency management

// Dependency Management
// - Use a single source of truth for dependencies
// - Pin dependency versions for reproducible builds
// - Prefer internal dependencies over external when available
// - Document dependency relationships between projects

// Build System
// - Use a build system that supports monorepos (e.g., Bazel, Nx, Turborepo)
// - Implement incremental builds for efficiency
// - Define clear visibility rules between projects
// - Use consistent build patterns across all projects

// Development Workflow
// - Implement CI/CD pipelines that understand the monorepo structure
// - Use tools that support selective testing and building
// - Maintain consistent coding standards across all projects
// - Document cross-project dependencies and interfaces

// Common Patterns
// - Define shared libraries for common functionality
// - Use consistent project structures within each category
// - Implement clear API boundaries between projects
// - Document the purpose and relationships of each project
```

## How to Use

1. Copy the above `.cursorrules` content to a file named `.cursorrules` in the root of your repository.
2. Customize it to match your project's specific needs and conventions.
3. Commit the file to your repository.

The content of the `.cursorrules` file will be appended to the global "Rules for AI" settings in Cursor, providing project-specific guidance to Cursor AI.

## Benefits

- Helps Cursor AI understand the monorepo structure and organization
- Provides context about project relationships and dependencies
- Guides Cursor AI to suggest appropriate cross-project solutions
- Ensures consistent code organization across the monorepo
- Improves code generation and understanding for monorepo-specific patterns

## Additional Resources

- [Monorepo Tools](https://monorepo.tools/)
- [Bazel for Monorepos](https://bazel.build/basics/monorepos)
- [Nx Documentation](https://nx.dev/getting-started/intro)
- [Turborepo Documentation](https://turbo.build/repo/docs)
- [Monorepo Best Practices](https://www.atlassian.com/git/tutorials/monorepos) 