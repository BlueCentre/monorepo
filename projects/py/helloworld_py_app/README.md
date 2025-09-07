# Python Hello World App

A simple Python "Hello World" application demonstrating basic Python packaging and containerization with Bazel.

The motivation for this project is to learn and explore how to build, run and test containers with a very basic Python example. The example reference we use comes from Aspect development who works closely with the Bazel community. Credits go to their example which can be found [here](https://github.com/aspect-build/bazel-examples/tree/main/oci_python_image).

## Changes

- [x] Organize sources into respective folders like src and tests
- [x] Used a slim container version instead of what comes with Aspect's example

## Roadmap

- [ ] Both Aspect's and our example are not using a truly distroless container implementation so we want to change that
- [ ] Extend additional examples to build more realworld workloads with dependency requirements
- [ ] Extend testing framework to more realistic

## Issues

- [ ] Follow-up on rules_pkg issue #153, more specifically pkg_tar, where a temporary workaround is implemented today
