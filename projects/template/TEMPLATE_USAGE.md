# Template Project Generation and Skaffold Development

This document explains how to use the project templates with proper Skaffold integration for development.

## Overview

The templates in this directory are designed to generate new projects that integrate seamlessly with the monorepo's build system. Each template includes:

- Jinja-templated source code files
- Dynamic Skaffold configuration with `dev` profiles  
- Kubernetes manifests templates
- Proper Bazel integration

## Quick Start

### 1. Generate a New Project

Use Copier to generate a new project from a template:

```bash
# From the monorepo root directory
cd /path/to/monorepo

# Generate a Python FastAPI project
copier copy projects/template/template_fastapi_app projects/py/my_new_api

# Generate a Go Gin project  
copier copy projects/template/template_gin_app projects/go/my_new_service

# Generate a Python CLI project
copier copy projects/template/template_typer_app projects/py/my_new_cli
```

### 2. Important: Project Placement

**Critical**: Always place generated projects in the correct language directory:
- **Python projects**: `projects/py/your_project_name/`
- **Go projects**: `projects/go/your_project_name/`  
- **Java projects**: `projects/java/your_project_name/`

This ensures the templated Skaffold configuration can find the correct Bazel targets.

### 3. Development with Skaffold

Once your project is generated, you can immediately start development:

```bash
# Navigate to your new project
cd projects/py/my_new_api  # or projects/go/my_new_service

# Start development mode with hot reload
skaffold dev

# The dev profile automatically activates with:
# - Local image builds (push: false)
# - Fast Kubernetes deployment
# - Port forwarding for easy access
```

## Template Structure

Each template includes:

### Jinja Templates (.jinja files)
- Source code with dynamic project names and configurations
- Kubernetes manifests with proper resource naming
- Skaffold configuration adapted to project location

### Generated Files
When you run `copier copy`, these templates generate:
- `skaffold.yaml` - Pre-configured with dev profiles and correct Bazel targets
- `kubernetes/*.yaml` - Manifests with proper project naming  
- Source code files customized for your project

## Troubleshooting

### Issue: "Bazel target not found"
**Cause**: Project generated in wrong directory or incorrect project name
**Solution**: 
1. Ensure project is in correct language directory (`projects/py/`, `projects/go/`, etc.)
2. Verify project name follows naming conventions (alphanumeric, hyphens, underscores only)

### Issue: "skaffold dev fails to start"
**Cause**: Skaffold configuration pointing to template paths instead of project paths
**Solution**:
1. Verify you're using the `.jinja` template files (not the static `skaffold.yaml`)
2. Re-generate project with proper Copier command
3. Check that `skaffold.yaml` in generated project has your project name, not "template-*"

### Issue: "Kubernetes manifests not found"
**Cause**: Missing templated Kubernetes files
**Solution**:
1. Ensure `kubernetes/*.yaml.jinja` files exist in template
2. Verify Copier processed all template files correctly
3. Check that generated `kubernetes/` directory has `.yaml` files (not `.yaml.jinja`)

## Template Development

When modifying templates:

### 1. Always use `.jinja` suffix for template files
```
skaffold.yaml.jinja          ✅ Correct
kubernetes/deployment.yaml.jinja  ✅ Correct  
skaffold.yaml               ❌ Static file, won't be processed
```

### 2. Use template variables consistently
```yaml
# In skaffold.yaml.jinja
metadata:
  name: {{ project_name }}    ✅ Dynamic

# In kubernetes/deployment.yaml.jinja  
metadata:
  name: {{ project_name }}    ✅ Matches Skaffold config
```

### 3. Reference correct Bazel targets
```yaml
# In skaffold.yaml.jinja for Python projects
bazel test //projects/py/{{ project_name }}/...

# In skaffold.yaml.jinja for Go projects  
bazel test //projects/go/{{ project_name }}/...
```

## Available Templates

### 1. FastAPI Template (`template_fastapi_app`)
- **Target Directory**: `projects/py/your_project_name/`
- **Features**: Full-featured web API with database, auth, rate limiting
- **Kubernetes**: Deployment + Service + Ingress + Database
- **Development**: Advanced dev profile with smoke tests

### 2. Gin Template (`template_gin_app`)  
- **Target Directory**: `projects/go/your_project_name/`
- **Features**: Go web service with HTTP API
- **Kubernetes**: Deployment + Service
- **Development**: Basic dev profile with port forwarding

### 3. Typer Template (`template_typer_app`)
- **Target Directory**: `projects/py/your_project_name/`  
- **Features**: Python CLI application
- **Kubernetes**: Job (one-time execution)
- **Development**: Job-based dev profile

## Example Workflow

Complete example of creating and developing a new FastAPI project:

```bash
# 1. Generate project from template
cd /path/to/monorepo
copier copy projects/template/template_fastapi_app projects/py/awesome_api
# Answer prompts: project_name="awesome_api", etc.

# 2. Verify generated files
ls projects/py/awesome_api/
# Should include: skaffold.yaml, kubernetes/, app/, etc.

# 3. Check Skaffold configuration  
grep "name:" projects/py/awesome_api/skaffold.yaml
# Should show: name: awesome_api (not template-fastapi-app)

# 4. Start development
cd projects/py/awesome_api
skaffold dev
# Automatically builds, deploys, and starts port forwarding

# 5. Access your application
curl http://localhost:8000/health
# Should return health status from your new API
```

This workflow ensures your generated project has properly configured Skaffold integration that works with the monorepo build system.