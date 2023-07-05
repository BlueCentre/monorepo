# Overview of design

This topic tackles how we want to approach day 1 development. Essentially we want to operationalize blueprints (templates).

## Goals

Through automation, we want to help guide developer engineering in starting their journey on day 1. The outcome of this automation should produce a working code that builds, tests, and deploys as a kubernetes application for local development and CI/CD pipelines.

* I am a _____ engineer, and I want to start developing a new _____ project.

| Engineer | Project |
|----------|---------|
| Data Engineer | Composer Project |
| Software Engineer | FastAPI Project |
| ... | ... |

## Strategies

Similar to the CookieCutter approach, we will be using Copier to handle the automation of our blueprints for instanciating new engineering projects including any supporting dependencies such as libraries.

## Objectives

Any engineering should be able to start developing new features and functionality in 10 minutes or less.

## Tactics

The scope of this design doc is to setup a framework to handle the boilerplating approach of new projects that is easy to maintain. We will only support instanciation of new projects, but will not aim to keep the implementation in sync with templates at this stage for the MVP.

Create an example of a FastAPI project as 90% of our codebase is implemented in Python today. Contributions from subject matter experts (SMEs) is expected. We will need contributions from Goland and Java SMEs to buil out additional templates using [Copier](https://github.com/copier-org/copier/blob/master/docs/comparisons.md).

All templates are denoted with the prefix `template_` as a convention to quicky deliniate between implementation code. They live in their respective folder structure as apposed to a central top level structure for the time being until we have a reasonible argument for centralizing them.

Testing and validating templates is currently not feasible as the templates are not deterministic, so testing will be handled within the blueprint post instantiation. We will need to document the development process for templates to ensure high code quality.
