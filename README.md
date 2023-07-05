# Monorepo Blueprints

A place to develop [monorepo](https://monorepo.tools/#what-is-a-monorepo) patterns.

## Overview

Unlike other examples and demos out in the wild, we have a loftier goals. If you don't see the following objectives being met, I wouldn't bother digging much further since technologies and versions change so much that anything here would almost be useless similar to what my experience was while looking for best practices and more indepth examples that can be used as blueprints rather than a one time presentation.

## Blueprint Capability

### Continuous Development

- [x] [Skaffold for continuous development](https://skaffold.dev/docs/quickstart/#use-skaffold-for-continuous-development)
    - [ ] [Skaffold for CI](https://skaffold.dev/docs/quickstart/#use-skaffold-for-continuous-integration)
    - [ ] [Skaffold for CD](https://skaffold.dev/docs/quickstart/#use-skaffold-for-continuous-delivery)
- [x] [Bazel](https://en.wikipedia.org/wiki/Bazel_(software))
- [ ] [Pants]()

### Continuous Integration

- [x] [Github Actions](https://docs.github.com/en/actions)
- [ ] [Cloud Build](https://cloud.google.com/build)
- [ ] [CircleCI](https://circleci.com/)
- [ ] [Harness](https://www.harness.io/)

### Continuous Deployment

- [ ] [Argo CD](https://github.com/argoproj/argo-cd)
- [ ] [Cloud Deploy](https://cloud.google.com/deploy)

### Progressive Delivery

- [ ] [Argo Rollouts](https://github.com/argoproj/argo-rollouts)
- [ ] [Cloud Deploy](https://cloud.google.com/deploy)

### Framework Best Practice

- [ ] React
- [ ] FastAPI
- [ ] Gin
- [ ] Springboot
- [ ] Typer

## Quickstart

1. Download latest [bazelisk](https://bazel.build/install/bazelisk)
1. Download latest [skaffold](https://skaffold.dev/docs/install/)
1. Download latest [minikube](https://minikube.sigs.k8s.io/docs/start/)

## Motivation

- [Salesforce](https://www.youtube.com/watch?v=KZIYdxsRp4w)
- [Uber](https://www.uber.com/blog/go-monorepo-bazel/)
- [Twitter](https://opensourcelive.withgoogle.com/events/bazelcon2020/watch?talk=day1-talk2)
- [BazelCon - bzlmod](https://www.youtube.com/watch?v=2Nn71RV_yhI)
- [DevOps Toolkit - skaffold](https://www.youtube.com/watch?v=qS_4Qf8owc0)

## Goals

1. Quick, reliable and convenient builds for SDLC.
1. Manage dependencies across all projects.
1. Manage [polyglot](https://www.pluralsight.com/blog/software-development/how-polyglot-dev-team) builds.
1. Manage blueprints for rapid application development.
1. Constant evaluation of the technology stack and scale for thousands of engineers.

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
    - [ ] Test multi-version golang
- [ ] Setup e2e Springboot example
    - [ ] Test multi-version springboot
- [ ] Setup e2e React example
- [x] OCI container support
    - [ ] Test container structure
- [ ] Define promotion strategy supporting multi-release cadance
- [ ] Research and setup container & kubernetes development with Skaffold
- [ ] Research build systems like Cloud Build, Harness.io, etc
- [ ] Research [remote execution services](https://bazel.build/community/remote-execution-services) like Buildkite, BuildBuddy, etc
- [ ] Research testing best practice
- [ ] Document VSCode and PyCharm IDE development environment
- [ ] Tooling for boilerplate project creation
    - [ ] CookieCutter or Copier

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

## References

- https://github.com/aspect-build/bazel-examples/tree/main
- https://s.itho.me/ccms_slides/2022/9/27/8dc835fc-b6f6-4656-84d4-53df725d1d6e.pdf
- https://nubenetes.com/kubernetes-based-devel/
- https://blog.getambassador.io/skaffold-vs-telepresence-comparing-kubernetes-inner-development-loop-tools-c8abd70545e5
- https://sixfeetup.com/blog/common-kubernetes-concerns
