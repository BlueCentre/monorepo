"""Wrap pytest"""

load("@rules_python//python:defs.bzl", "py_test")
load("@pip_deps//:requirements.bzl", "requirement")

def pytest_test(name, srcs, deps = [], args = [], data = [], **kwargs):
    """
    Call pytest
    """
    py_test(
        name = name,
        srcs = [
            "//tools/pytest:pytest_wrapper.py",
        ] + srcs,
        main = "//tools/pytest:pytest_wrapper.py",
        args = [
            "--capture=no",
            "--black",
            "--pylint",
            "--pylint-rcfile=$(location //tools/pytest:.pylintrc)",
            # "--mypy",
        ] + args + ["$(location :%s)" % x for x in srcs],
        python_version = "PY3",
        srcs_version = "PY3",
        deps = deps + [
            requirement("pytest"),
            requirement("pytest-black"),
            requirement("pytest-pylint"),
            # requirement("pytest-mypy"),
        ],
        data = [
            "//tools/pytest:.pylintrc",
        ] + data,
        **kwargs
    )
