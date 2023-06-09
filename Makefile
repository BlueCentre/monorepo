query:
	bazel query //...

build:
	bazel build //...

test:
	bazel test //...

clean:
	bazel clean --async

update: update_aspect_bazelrc update_python_requirements
	echo "Running update..."

update_aspect_bazelrc:
	bazel run //.aspect/bazelrc:update_aspect_bazelrc_presets

update_python_requirements:
	bazel run //third_party/python:requirements_3_11.update
	bazel run //third_party/python:requirements_3_10.update
	bazel run //third_party/python:requirements_3_9.update
	bazel run //third_party/python:requirements_3_8.update



run_py_calculator:
	bazel run //projects/py_calculator_cli_app:app

run_flask_calculator:
	bazel run //projects/py_calculator_flask_app:app

run_fastapi_echo:
	bazel run //projects/py_echo_fastapi_app:run

run_oci_py_helloworld:
	bazel build //projects/py_helloworld_cli_app:tarball
	docker load --input `bazel cquery --output=files //projects/py_helloworld_cli_app:tarball`
	docker run --rm local/py_helloworld_cli_app:latest


test_libs:
	bazel test //libs/...

test_py_calculator:
	echo "TODO"

test_flask_calculator:
	echo "TODO"

test_fastapi_echo:
	bazel test //projects/py_echo_fastapi_app:webapp_test

test_oci_py_helloworld:
	bazel test //projects/py_helloworld_cli_app:test


git_push:
	git push origin `git rev-parse --abbrev-ref HEAD`
