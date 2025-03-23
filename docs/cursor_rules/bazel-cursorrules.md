# Bazel - Rules for AI

This file provides guidance for working with Bazel build system in your projects.

## Project Structure

- `WORKSPACE.bazel`: Defines external dependencies
- `MODULE.bazel`: Defines module dependencies (Bazel 6+)
- `BUILD.bazel`: Defines build targets in each directory
- `tools/`: Contains Bazel-specific tooling
- `third_party/`: Contains third-party dependencies

## General Guidelines

1. Prefer Bzlmod (MODULE.bazel) over WORKSPACE for dependency management when using Bazel 6+
2. Keep BUILD files simple and focused on a single responsibility
3. Use consistent naming conventions for targets
4. Leverage Bazel's caching capabilities by ensuring hermetic builds
5. Minimize the use of genrules in favor of proper rule implementations

## Implementation Details

- Use appropriate rule types for different languages (e.g., `py_binary`, `java_library`, `cc_binary`)
- Define clear visibility for targets to control dependencies
- Use labels consistently with the `//path/to/package:target` format
- Leverage Bazel's test infrastructure for reliable testing

## Example .cursorrules File

```
// Bazel - Rules for AI
// This file provides guidance for working with Bazel build system

// Project Structure
// - WORKSPACE.bazel: Defines external dependencies
// - MODULE.bazel: Defines module dependencies (Bazel 6+)
// - BUILD.bazel: Defines build targets in each directory
// - tools/: Contains Bazel-specific tooling
// - third_party/: Contains third-party dependencies

// General Guidelines
// 1. Prefer Bzlmod (MODULE.bazel) over WORKSPACE for dependency management when using Bazel 6+
// 2. Keep BUILD files simple and focused on a single responsibility
// 3. Use consistent naming conventions for targets
// 4. Leverage Bazel's caching capabilities by ensuring hermetic builds
// 5. Minimize the use of genrules in favor of proper rule implementations

// Dependency Management
// - Use repository rules to fetch external dependencies
// - Pin dependency versions for reproducible builds
// - Group related dependencies in a single repository rule when possible
// - Use Bazel modules for modern dependency management

// Build Rules
// - Use appropriate rule types for different languages (e.g., py_binary, java_library, cc_binary)
// - Define clear visibility for targets to control dependencies
// - Use labels consistently with the //path/to/package:target format
// - Leverage Bazel's test infrastructure for reliable testing

// Performance Considerations
// - Use query to understand build dependencies
// - Leverage remote caching and execution when available
// - Minimize the size of action inputs and outputs
// - Use appropriate sandboxing settings for your environment

// Common Patterns
// - Define library targets separately from binaries
// - Use filegroups for organizing non-buildable files
// - Leverage macros for repeated patterns, but prefer rules for complex logic
// - Use select() for platform-specific configurations
```

## How to Use

1. Copy the above `.cursorrules` content to a file named `.cursorrules` in the root of your repository.
2. Customize it to match your project's specific needs and conventions.
3. Commit the file to your repository.

The content of the `.cursorrules` file will be appended to the global "Rules for AI" settings in Cursor, providing project-specific guidance to Cursor AI.

## Benefits

- Helps Cursor AI understand Bazel's build structure and concepts
- Provides context about best practices for Bazel usage
- Guides Cursor AI to suggest appropriate build configurations
- Ensures consistent build file structure across the project
- Improves code generation and understanding for Bazel-specific files

## Additional Resources

- [Bazel Documentation](https://bazel.build/docs)
- [Bazel Rules Reference](https://bazel.build/reference/be/overview)
- [Bzlmod Documentation](https://bazel.build/external/module)
- [Bazel Query Reference](https://bazel.build/query/guide)
- [Bazel Best Practices](https://bazel.build/basics/best-practices) 