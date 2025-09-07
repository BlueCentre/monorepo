"""Wrap pytest"""

load("@pip_deps//:requirements.bzl", "requirement")
load("@rules_python//python:defs.bzl", "py_test")

def pytest_test(name, srcs, deps = [], args = [], data = [], **kwargs):
    """
    Call pytest with ruff linting
    """
    py_test(
        name = name,
        srcs = [
            "//tools/pytest:pytest_wrapper.py",
        ] + srcs,
        main = "//tools/pytest:pytest_wrapper.py",
        args = [
            "--capture=no",
            # Using ruff for fast linting and formatting checks
            # "--mypy",  # Can be enabled for type checking
        ] + args + ["$(location :%s)" % x for x in srcs],
        # python_version = "PY3",
        # srcs_version = "PY3",
        deps = deps + [
            requirement("pytest"),
            # requirement("pytest-mypy"),  # Can be enabled for type checking
        ],
        data = data,
        **kwargs
    )
