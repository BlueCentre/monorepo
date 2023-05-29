# Useful Commands

bazel --version
bazel clean

## General

bazel build //...
bazel build //projects/...
bazel build //projects/my-app/...
OR
bazel build ...
bazel build projects/...
bazel build projects/my-app/...

## 3rd Party PIP

bazel run //third_party/python:requirements_3_11.update
bazel run //third_party/python:requirements_3_10.update
bazel run //third_party/python:requirements_3_9.update
bazel run //third_party/python:requirements_3_8.update

## Common Library

bazel build projects/common/calculator/...
bazel test projects/common/calculator/...
bazel test --test_verbose_timeout_warnings projects/common/calculator/...

## Apps

bazel run projects/python-app:app
bazel query projects/python-app:app --output=build

## Flask Apps

bazel run projects/python-flask:app
bazel query projects/python-flask:*
bazel query projects/python-flask:app --output=build
