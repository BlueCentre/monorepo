# BlueCentre Monorepo - GitHub Copilot Instructions

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Overview

This is a sophisticated monorepo built with Bazel 8.3.1 that supports Python, Java, and Go applications. It uses Skaffold for Kubernetes development workflows, offers both Terraform and Pulumi infrastructure options, and integrates with BuildBuddy for remote builds and caching.

## Critical Prerequisites & Network Requirements

**NETWORK ACCESS REQUIRED**: This repository requires external network access to function properly. Many core operations will fail in network-restricted environments.

### Required External Access

- `releases.bazel.build` - Bazel/Bazelisk downloads (CRITICAL)
- `storage.googleapis.com` - Skaffold downloads
- `packages.microsoft.com` - Build dependencies  
- `maven.google.com` and `repo1.maven.org` - Java dependencies
- `registry.bazel.build` - Bazel module registry

If network access is restricted, document this limitation: "Network access blocked - core build tools unavailable."

## Working Effectively

### Bootstrap, Build, and Test (Full Workflow)

**NEVER CANCEL: All builds take 10-45 minutes. ALWAYS set timeouts to 60+ minutes.**

```bash
# 1. Install Bazelisk (if not available)
curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64 -o /usr/local/bin/bazel
chmod +x /usr/local/bin/bazel

# 2. Install Skaffold  
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
chmod +x skaffold && sudo mv skaffold /usr/local/bin

# 3. Verify tools
bazel version                    # Should show Bazel 8.3.1
skaffold version
kubectl version --client
docker version

# 4. Build everything (NEVER CANCEL - takes 15-45 minutes)
bazel build //... --config=ci
# Timeout: 60+ minutes, Expected: 15-45 minutes

# 5. Test everything (NEVER CANCEL - takes 10-30 minutes) 
bazel test //... --config=ci
# Timeout: 60+ minutes, Expected: 10-30 minutes

# 6. Alternative builds for development
bazel build //... --config=dev          # Faster dev build
bazel test //... --config=progressive   # Progressive testing
```

### Alternative Validation When Bazel is Blocked

If Bazel is unavailable due to network restrictions, validate using direct language tools:

```bash
# Test Python applications
cd projects/py/helloworld_py_app
PYTHONPATH=/home/runner/work/monorepo/monorepo python3 app/__main__.py
# Expected output: "Hello Jane!"

# Test Java applications  
cd projects/java/simple_java_app
javac src/main/java/com/example/HelloWorld.java
java -cp src/main/java com.example.HelloWorld
# Expected output: "Hello, World!"

# Test Go functionality
echo 'package main
import "fmt"
func main() { fmt.Println("Hello, Go!") }' > /tmp/test.go
go run /tmp/test.go
# Expected output: "Hello, Go!"
```

## Skaffold Development Workflow

### Template FastAPI App (Primary Example)

```bash
# Deploy without Istio (basic setup)
skaffold run -m template-fastapi-app -p dev
# Expected: Creates namespace, deploys app and database

# Deploy with Istio rate limiting  
skaffold run -m template-fastapi-app -p istio-rate-limit
# Expected: Installs Istio, configures rate limiting

# Development mode with hot reload
skaffold dev -m template-fastapi-app -p dev
# NEVER CANCEL - runs continuously for development

# Test the running application
kubectl port-forward -n template-fastapi-app svc/template-fastapi-app 8080:80 &
curl http://localhost:8080/health        # Should return 200 OK
curl http://localhost:8080/api/v1/items  # Should return JSON items

# Cleanup
skaffold delete -m template-fastapi-app -p dev
```

## Infrastructure as Code Setup

Choose either Terraform OR Pulumi (both provide identical functionality):

### Terraform Option
```bash
cd terraform_dev_local
terraform init
terraform plan    # Takes 2-5 minutes
terraform apply   # Takes 10-20 minutes, NEVER CANCEL
```

### Pulumi Option  
```bash
cd pulumi_dev_local
pulumi up         # Takes 10-20 minutes, NEVER CANCEL
```

## Build Configurations & Timing

**CRITICAL: NEVER CANCEL builds - they may appear hung but are processing**

| Command | Expected Time | Timeout | Notes |
|---------|---------------|---------|-------|
| `bazel build //...` | 15-45 min | 60+ min | Full monorepo build |
| `bazel test //...` | 10-30 min | 45+ min | Full test suite |
| `bazel build //... --config=dev` | 5-15 min | 30+ min | Development build |
| `bazel test //... --config=progressive` | 5-20 min | 30+ min | Progressive tests |
| `skaffold build` | 5-15 min | 30+ min | Container builds |
| `skaffold run` | 10-25 min | 45+ min | Full deployment |
| `terraform apply` | 10-20 min | 30+ min | Infrastructure setup |

## Validation Scenarios

### End-to-End FastAPI Template Validation

**ALWAYS run this scenario after making changes to validate functionality:**

```bash
# 1. Build and test the template app
bazel build //projects/template/template_fastapi_app/...
bazel test //projects/template/template_fastapi_app/...

# 2. Deploy the application
cd projects/template/template_fastapi_app
skaffold run -p dev

# 3. Test core functionality
kubectl port-forward -n template-fastapi-app svc/template-fastapi-app 8080:80 &

# Test health endpoint
curl -f http://localhost:8080/health
# Expected: 200 OK with JSON health status

# Test API endpoints
curl -f http://localhost:8080/api/v1/items
# Expected: 200 OK with JSON array of items  

# Test authentication (if configured)
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}'
# Expected: JWT token response

# 4. Cleanup
skaffold delete -p dev
```

## Common Commands & Locations

### Repository Structure (Reference)
```
monorepo/
├── projects/                    # All applications
│   ├── py/                      # Python applications
│   │   ├── helloworld_py_app/   # Simple Python app
│   │   ├── calculator_cli_py_app/ # CLI calculator
│   │   ├── echo_fastapi_app/    # Basic FastAPI app
│   │   └── devops_fastapi_app/  # FastAPI with DevOps features
│   ├── java/                    # Java applications
│   │   ├── simple_java_app/     # Basic Java app
│   │   ├── hello_springboot_app/ # Spring Boot hello world
│   │   └── rs_springboot_app/   # RESTful Spring Boot service
│   ├── template/                # Project templates
│   │   ├── template_fastapi_app/ # Production FastAPI template
│   │   ├── template_gin_app/    # Go Gin template
│   │   └── template_typer_app/  # Python Typer CLI template
│   └── microservices-demo/     # Microservices examples
├── terraform_dev_local/        # Terraform local infrastructure
├── pulumi_dev_local/           # Pulumi local infrastructure
├── docs/                       # Documentation
├── third_party/                # External dependencies
└── tools/                      # Development tools
```

### Frequently Used Commands
```bash
# Build specific project
bazel build //projects/py/helloworld_py_app/...
bazel build //projects/template/template_fastapi_app/...

# Test specific project  
bazel test //projects/py/helloworld_py_app/...

# Update Python dependencies
bazel run //third_party/python:requirements_3_11.update

# Build with different configurations
bazel build //... --config=ci           # CI configuration
bazel build //... --config=dev          # Development configuration  
bazel build //... --config=progressive  # Progressive testing

# Skaffold operations
skaffold build -m template-fastapi-app  # Build containers
skaffold test -m template-fastapi-app   # Run tests
skaffold run -m template-fastapi-app -p dev # Deploy application
skaffold delete -m template-fastapi-app -p dev # Clean up
```

## Known Issues & Workarounds

### Java Projects Currently Excluded
Some Java projects are excluded in `.bazelignore` due to Maven dependency issues:
- `projects/java/example1_java_app/`
- `projects/java/example2_java_app/` 
- `projects/java/hello_springboot_app/`
- `projects/java/rs_springboot_app/`

These require additional Maven repository configuration to build.

### Network Connectivity Issues
If you encounter "dial tcp" or "server misbehaving" errors, the environment has network restrictions. Document this limitation and use alternative validation approaches.

### Build Warnings
The build produces expected warnings from:
- zlib C functions without prototypes
- protobuf deprecated functions
- libtool duplicate library warnings

These warnings are cosmetic and don't affect functionality.

## Before Committing Changes

**ALWAYS run these validation steps before committing:**

```bash
# 1. Build and test (NEVER CANCEL - wait for completion)
bazel build //... --config=ci   # 15-45 minutes
bazel test //... --config=ci    # 10-30 minutes

# 2. Test template app deployment  
cd projects/template/template_fastapi_app
skaffold build                  # 5-15 minutes
skaffold test                   # 5-10 minutes

# 3. Validate core languages work directly (if Bazel blocked)
# [Use alternative validation commands from above]

# 4. Check for lint issues (if project has linting configured)
# Most projects don't have separate linting - Bazel handles this
```

## Critical Reminders

- **NEVER CANCEL** any build or test command - they may take 45+ minutes
- **ALWAYS** set timeouts to 60+ minutes for build commands  
- **ALWAYS** set timeouts to 45+ minutes for test commands
- Network access to `releases.bazel.build` is **REQUIRED** for Bazel
- Use direct language tools for validation when Bazel is blocked
- The "make quickstart" command referenced in documentation **does not exist**
- Template FastAPI app is the primary integration example - always test it after changes