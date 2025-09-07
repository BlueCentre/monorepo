# Simple Java App

A collection of simple Java applications demonstrating basic Java features without external dependencies.

## Features

- **HelloWorld**: Classic "Hello, World!" application
- **WebServer**: Simple HTTP server using Java's built-in `HttpServer`
- **No External Dependencies**: Uses only Java standard libraries

## Usage

```bash
# Build all targets
bazel build //projects/java/simple_java_app/...

# Run HelloWorld application
bazel run //projects/java/simple_java_app:hello

# Run WebServer application  
bazel run //projects/java/simple_java_app:webserver

# Run tests
bazel test //projects/java/simple_java_app:hello_test
```

## Web Server

The WebServer application starts a simple HTTP server on port 8080:

```bash
# Start the server
bazel run //projects/java/simple_java_app:webserver

# Test the endpoint
curl http://localhost:8080/api/hello
# Expected output: Hello, World!
```

## Project Structure

```
simple_java_app/
├── src/
│   ├── main/java/com/example/
│   │   ├── HelloWorld.java      # Main HelloWorld application
│   │   └── WebServer.java       # HTTP server application
│   └── test/java/com/example/
│       ├── HelloWorldTest.java  # Basic tests
│       └── WebServerTest.java   # Server tests
├── BUILD.bazel                  # Bazel build configuration
└── README.md                   # This file
```

## Development

This project demonstrates:

- Simple Java applications with main methods
- Basic HTTP server using `com.sun.net.httpserver.HttpServer`
- Bazel build configuration for Java
- Basic testing without external frameworks

## Monorepo Integration

This project is fully integrated with the monorepo build system using Bazel:

```bash
# Build everything in the monorepo
bazel build //...

# Test everything in the monorepo
bazel test //...

# Build and run specific applications
bazel run //projects/java/simple_java_app:hello
bazel run //projects/java/simple_java_app:webserver
```

This project demonstrates:
- Simple Java applications with minimal dependencies
- Consistent build patterns across the monorepo
- Standard project structure for Java applications
- Integration with the monorepo testing framework