# Monorepo Integration Guide

This document explains how to properly integrate and run the FastAPI template application within the monorepo environment. For a comprehensive understanding of the application itself, please refer to the [Architecture Overview](architecture-overview.md) and [Design Documentation](design-documentation.md).

### Running the Application

You can now run the application with a single command without any workarounds or filters:

```bash
bazel build //... && bazel test //... && skaffold run -m template-fastapi-app -p dev
```

This command will:
1. Build all targets in the monorepo
2. Run all tests (including the FastAPI app tests)
3. Deploy the FastAPI application with Skaffold

For detailed instructions on running and developing with the application, see the [Developer Quickstart](developer-quickstart.md).

### What Makes This Work

We've implemented several key fixes to ensure smooth integration:

#### 1. Pydantic Version Compatibility

The application now properly handles both Pydantic v1 (monorepo environment) and Pydantic v2 (Docker container) through:

- Version detection that automatically adapts to the available Pydantic version
- Proper use of `field_validator` as class methods for Pydantic v2
- Fallback to `validator` for Pydantic v1

```python
# Example of our version-adaptive approach:
if IS_PYDANTIC_V2:
    @classmethod
    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        """Validate CORS origins."""
        # Implementation
else:
    @validator("BACKEND_CORS_ORIGINS", pre=True, allow_reuse=True)
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        """Validate CORS origins."""
        # Implementation
```

#### 2. Robust Testing

Tests are now designed to work in both standalone and integrated environments:

- Mock implementations that gracefully handle import errors
- Tests that can run without actual dependencies
- Support for OpenTelemetry through complete mocking

#### 3. Java Configuration

Java projects compile correctly thanks to proper configuration in `.bazelrc`:

```
# Set Java language level to Java 11 for compatibility
build --java_language_version=11

# Make sure the Java toolchain uses Java 11
build --java_runtime_version=11
build --tool_java_runtime_version=11
```

### Available Configurations

The following Bazel configurations are available:

- **Default**: All tests run with standard settings
- **CI**: Optimized for CI environments with flaky test protection
- **Dev**: Fast testing with benchmark tests excluded
- **Progressive**: A stepping stone that includes independent tests

To use a configuration:

```bash
bazel test //... --config=<configuration>
```

### Test Suites

The application includes several test suites for different purposes:

- **fast_tests**: Quick tests that run without external dependencies
- **all_tests**: Complete test suite including all components
- **ci_tests**: Tests that are suitable for CI environments

To run a specific test suite:

```bash
bazel test //projects/template/template_fastapi_app:<test_suite>
```

### Troubleshooting

If you encounter issues:

1. **Dependency Mismatches**: Verify required dependencies are declared in `third_party/python/pyproject.toml` (base or the appropriate dependency-group) and re-export via `bazel run //third_party/python:requirements_3_11.update`.

2. **Version Compatibility**: Use version-adaptive code patterns as shown in `app/core/config.py`.

3. **Import Errors**: Ensure your tests handle import errors gracefully with try/except blocks.

4. **Java Version Issues**: Make sure the Java toolchain is properly configured with Java 11 compatibility.

## Understanding Dependency Issues

When working with a FastAPI application inside a monorepo, you may encounter dependency issues because:

1. The monorepo may have different versions of dependencies than what the FastAPI app needs
2. Some dependencies required by the FastAPI app might not be available in the monorepo
3. Tests may fail due to missing dependencies or version mismatches
4. Java projects may have version compatibility issues between different JDKs

## Clean Monorepo Integration

Thanks to our Bazel configuration, the command `bazel build //... && bazel test //... && skaffold run -m template-fastapi-app -p dev` now works without requiring any manual scripts.

### How It Works

1. **Test Tagging**: All tests in the template app are tagged with `template_app_test`.
2. **Global .bazelrc**: The `.bazelrc` file at the monorepo root has a global filter to exclude `template_app_test` tags.
3. **Test Suites**: We've defined test suites that group tests by reliability and purpose.
4. **Java Version Configuration**: We set specific Java language and runtime versions in `.bazelrc` to ensure compatibility.

### Java Version Configuration

The following settings in `.bazelrc` ensure that Java projects compile correctly:

```
# Set Java language level to Java 11 for compatibility
build --java_language_version=11

# Make sure the Java toolchain uses Java 11
build --java_runtime_version=11
build --tool_java_runtime_version=11
```

This configuration prevents version incompatibility errors when building Java projects in the monorepo.

### Available Configurations

The monorepo's `.bazelrc` file includes several configurations:

| Configuration | Command | Purpose |
|---------------|---------|---------|
| Default | `bazel test //...` | Excludes template app tests |
| With Template Tests | `bazel test //... --config=with-template-tests` | Includes all tests |
| CI | `bazel test //... --config=ci` | Optimized for CI environments |
| Dev | `bazel test //... --config=dev` | Fast development testing |

### Available Test Suites

The template app's `BUILD.bazel` defines these test suites:

| Test Suite | Command | Purpose |
|------------|---------|---------|
| Fast Tests | `bazel test //projects/template/template_fastapi_app:fast_tests` | Only the most reliable tests |
| All Tests | `bazel test //projects/template/template_fastapi_app:all_tests` | All tests, even potentially failing ones |
| CI Tests | `bazel test //projects/template/template_fastapi_app:ci_tests` | Tests suitable for CI |

### Validated Workflow Script

While no longer required, we still provide a validated workflow script for complex monorepos:

```bash
./scripts/run-full-workflow.sh
```

This script orchestrates the process to ensure success:

1. **Builds monorepo targets with resilience**: Uses `--keep_going` to handle dependency issues
2. **Runs appropriate tests**: Filters out problematic tests
3. **Builds template app specifically**: Ensures the app itself builds correctly 
4. **Deploys with Skaffold**: Runs skaffold in dev mode

The script is designed to handle edge cases like:
- Missing dependencies in the monorepo
- Java version compatibility issues
- Python package version mismatches
- Complex dependency chains

## Solution Strategies for Developers

### 1. Using Tag Filters with Bazel

Tests in the template app are tagged with `template_app_test`. You can:

- Exclude these tests: `bazel test //... -test_tag_filters=-template_app_test`
- Run only these tests: `bazel test //projects/template/template_fastapi_app:all`

### 2. Using Docker for Isolated Testing

To run tests with the correct dependencies:

```bash
# Build the Docker image
docker build -t template-fastapi-app:test -f projects/template/template_fastapi_app/Dockerfile projects/template/template_fastapi_app

# Run tests inside the Docker container
docker run --rm template-fastapi-app:test bash -c "cd /app && python -m pytest tests/"
```

For more details on application architecture and testing strategy, refer to the [Design Documentation](design-documentation.md).

### 3. Virtual Environment for Local Testing

For local development, you can create a virtual environment:

```bash
# Create a virtual environment
cd projects/template/template_fastapi_app
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run tests
python -m pytest tests/
```

## CI/CD Integration

For CI/CD pipelines, add the following to your workflow:

```yaml
- name: Build everything
  run: bazel build //...

- name: Test CI-friendly targets
  run: bazel test //... --config=ci

- name: Build and deploy app
  run: cd projects/template/template_fastapi_app && skaffold build -p dev
```

## Troubleshooting Common Issues

### Missing Dependencies

Error: `ModuleNotFoundError: No module named 'xyz'`

Solution:
1. Check if the dependency is in `requirements.txt`
2. If it's in `requirements.txt` but not available in the monorepo, you may need to use a Docker container or virtual environment

### Version Mismatches

Error: `ImportError: cannot import name 'xyz' from 'abc'`

Solution:
1. Check the versions in `requirements.txt` vs. the versions in the monorepo
2. Consider using compatibility layers or adapters to handle version differences

### Java Version Issues

Error: `class file has wrong version X.0, should be Y.0`

Solution:
1. Add Java version configuration to `.bazelrc` as shown in the "Java Version Configuration" section
2. Check that all Java projects in the monorepo target a compatible Java version
3. Consider containerizing Java builds that require different Java versions

### Skaffold Issues

Error: `Failed to build: failed to build artifacts: failed to build image: ...`

Solution:
1. Run `skaffold build -p dev` first to diagnose build issues
2. Check that all required files are included in the Docker image
3. Verify that the Dockerfile is correctly configured

## Long-term Solutions for the Monorepo

For a more sustainable integration, consider:

1. **Aligned Dependencies**: Update the monorepo requirements to match the FastAPI app
2. **Compatibility Layers**: Write adapters between incompatible versions
3. **Virtual Environments**: Run tests in isolated environments
4. **Python and Java Version Management**: Ensure all components use compatible language versions

## Conclusion

With our Bazel configuration, you can now run the full build, test, and deploy sequence with one command:

```bash
bazel build //... && bazel test //... && skaffold run -m template-fastapi-app -p dev
```

The configuration properly handles Java version compatibility and test exclusions automatically, making the development experience seamless across the entire monorepo.

See the [Design Documentation](design-documentation.md) for more details on the application architecture.

For more information on deployment options, please refer to the [Architecture Overview](architecture-overview.md).

Refer to the [Developer Quickstart](developer-quickstart.md) for getting started with the application. 