# Useful Commands

```
bazel version
bazel info [release]
bazel info --show_make_env
bazel help info-keys
bazel clean --async
```

## Makefile

```
make dev_go_devops_cli_app
make dev_py_devops_fastapi_app
```

## General

```
bazel build //...
bazel build //projects/...
bazel build //projects/my_app/...
OR (for easier use of tab completion)
bazel build ...
bazel build projects/...
bazel build projects/my_app/...
```

## 3rd Party PIP

```
bazel run //third_party/python:requirements_3_11.update
bazel run //third_party/python:requirements_3_10.update
bazel run //third_party/python:requirements_3_9.update
bazel run //third_party/python:requirements_3_8.update
OR
make update
```

## Common Libraries

```
bazel build libs/calculator/...
bazel test libs/calculator/...
```

## CLI Apps

```
bazel run projects/py_calculator_cli_app:app
bazel query projects/py_calculator_cli_app:app --output=build
```

## Flask Apps

```
bazel run projects/py_calculator_flask_app:app
bazel query projects/py_calculator_flask_app:*
bazel query projects/py_calculator_flask_app:app --output=build
```

## FastAPI Apps

```

```

## Queries

```
bazel query --noimplicit_deps "deps(//libs/calculator:calculator_lib)"
bazel query --noimplicit_deps "deps(//libs/echo:echo_lib)"
bazel query --noimplicit_deps "deps(//libs/echo:echo_test)"
bazel query --noimplicit_deps "deps(//projects/py_calculator_cli_app:app)"
bazel query --noimplicit_deps "deps(//projects/py_echo_fastapi_app:webapp)"
```
