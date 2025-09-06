# Development Tools

This directory contains tools for development and build automation.

## Available Tools

### new_project
Interactive project generator that creates new projects from templates.

```bash
bazel run //tools:new_project
```

Creates new projects by:
1. Prompting for language (Python, Go, Java)
2. Prompting for project type (FastAPI, CLI, Gin, Spring Boot, etc.)  
3. Prompting for project name
4. Copying appropriate template or creating placeholder
5. Customizing project with user-provided details

See the main [README](../README.md#quick-project-creation) for supported languages and project types.

## Other Tools

- `pytest/` - Python testing configurations
- `scripts/` - Various build and development scripts
