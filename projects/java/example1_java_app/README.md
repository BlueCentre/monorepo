# Example Java App 1

A Java application demonstrating dependency management and testing with external libraries.

## Features

- **Number Comparison**: Compares two integers using Google Guava library
- **Unit Testing**: JUnit-based test suite
- **Maven Dependencies**: Demonstrates external dependency management in Bazel

## Current Status

⚠️ **Note**: This project currently has external dependencies (Google Guava and JUnit) commented out in the BUILD.bazel file due to Maven repository configuration issues in the monorepo.

## Usage

Once dependencies are configured:

```bash
# Build the application
bazel build //projects/java/example1_java_app:java-maven

# Run the application
bazel run //projects/java/example1_java_app:java-maven

# Run tests
bazel test //projects/java/example1_java_app:tests
```

## Current Alternative (Without External Dependencies)

For now, you can run a modified version without external dependencies:

```bash
# Build the simplified version
bazel build //projects/java/example1_java_app:java-simple

# Run the simplified version  
bazel run //projects/java/example1_java_app:java-simple
```

## Project Structure

```
example1_java_app/
├── src/
│   ├── main/java/com/example/myproject/
│   │   ├── App.java           # Main application with Guava dependency
│   │   └── AppSimple.java     # Alternative without dependencies
│   └── test/java/com/example/myproject/
│       ├── TestApp.java       # JUnit tests
│       └── TestAppSimple.java # Simple tests without JUnit
├── BUILD.bazel               # Bazel build configuration
└── README.md                # This file
```

## Dependencies

When fully configured, this project uses:
- **Google Guava**: For utility functions like `Ints.compare()`
- **JUnit**: For unit testing framework

## Roadmap

- [ ] Configure Maven repository in the monorepo to enable external dependencies
- [ ] Uncomment dependency declarations in BUILD.bazel
- [ ] Add more comprehensive tests
- [ ] Demonstrate additional Guava features

## Monorepo Integration

This project demonstrates:
- External dependency management with Bazel
- Java testing patterns
- Maven integration challenges in monorepos

**Note**: See [Maven dependency issue #153](https://github.com/BlueCentre/monorepo/issues/153) for progress on resolving external dependencies.