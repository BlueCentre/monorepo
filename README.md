# Monorepo Blueprint

## Overview

Unlike other examples and demos out in the wild, we have a loftier goals. If you don't see the following objectives being met, I wouldn't bother digging much further since technologies and versions change so much that anything here would almost be useless similar to what my experience was while looking for best practices and more indepth examples that can be used as blueprints rather than a one time presentation.

## Motivation

[Salesforce](https://www.youtube.com/watch?v=KZIYdxsRp4w)

## Goals

1. Keep dependencies and their versions up to date, not only with dependabot, but also breaking changes and automated tests.
1. Keep extending blueprints and add more complex use cases to demonstrate that these blueprints can scale beyond simple examples.
1. Avoid bad examples that are a dime a dozen and add little value outside of the beginner experience level. Here we are targeting the more advanced engineers looking to improve their own blueprints and hopefully even contribute back to the community.
1. Constantly reevaluate the technology stack to keep relevant.

## Objectives

1. Ensure efficient, correct, fast and repeatable builds
1. Ensure multi-language builds
1. Ensure high quality test coverage builds
1. Ensure [hermetic](https://bazel.build/basics/hermeticity) builds

## Roadmap

- [x] Setup basic Bazel builds and simple examples
- [x] Setup automated Bazel build + test using Github Actions
- [ ] Setup e2e Python example
- [ ] Test multi-version python
- [ ] Setup e2e Golang example
- [ ] Setup e2e Springboot example
- [ ] OCI container support
- [ ] Research and setup container & kubernetes development with Skaffold
- [ ] Research build systems like Cloud Build, Harness.io, etc
- [ ] Research [remote execution services](https://bazel.build/community/remote-execution-services) like Buildkite, BuildBuddy, etc
- [ ] Research testing best practice
- [ ] Document VSCode and PyCharm IDE development environment

## Directory Convention

```
monorepo/
|-- README.md
|-- Makefile
|-- skaffold.yaml
|-- WORKSPACE.bazel
|-- MODULE.bazel
|-- BUILD.bazel
|-- bazel-*/**                    -> bazel local directories not checked in
|-- fixes/**                      -> bazel temporary fixes
|-- docs/**                       -> please contribute!
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
|   |-- py_echo_fastapi_app/
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

# Useful Commands

bazel version
bazel info [release]
bazel help info-keys
bazel clean --async

## General

bazel build //...
bazel build //projects/...
bazel build //projects/my_app/...
OR
bazel build ...
bazel build projects/...
bazel build projects/my_app/...

## 3rd Party PIP

bazel run //third_party/python:requirements_3_11.update
bazel run //third_party/python:requirements_3_10.update
bazel run //third_party/python:requirements_3_9.update
bazel run //third_party/python:requirements_3_8.update

## Common Libraries

bazel build libs/calculator/...
bazel test libs/calculator/...
bazel test --test_verbose_timeout_warnings libs/calculator/...

## CLI Apps

bazel run projects/py_calculator_cli_app:app
bazel query projects/py_calculator_cli_app:app --output=build

## Flask Apps

bazel run projects/py_calculator_flask_app:app
bazel query projects/py_calculator_flask_app:*
bazel query projects/py_calculator_flask_app:app --output=build

## Queries

bazel query --noimplicit_deps "deps(//libs/calculator:calculator_lib)"
bazel query --noimplicit_deps "deps(//libs/echo:echo_lib)"
bazel query --noimplicit_deps "deps(//libs/echo:echo_test)"
bazel query --noimplicit_deps "deps(//projects/py_calculator_cli_app:app)"
bazel query --noimplicit_deps "deps(//projects/py_echo_fastapi_app:webapp)"
