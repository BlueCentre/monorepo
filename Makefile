.PHONY: query
query:
	bazel query //...

.PHONY: build
build:
	bazel build //...

.PHONY: test
test:
	bazel test //...

.PHONY: clean
clean:
	bazel clean --async

.PHONY: update
update: update_aspect_bazelrc update_python_requirements
	echo "Running update..."

update_aspect_bazelrc:
	bazel run //.aspect/bazelrc:update_aspect_bazelrc_presets

update_python_requirements:
	bazel run //third_party/python:requirements_3_11.update
	bazel run //third_party/python:requirements_3_10.update
	bazel run //third_party/python:requirements_3_9.update
	bazel run //third_party/python:requirements_3_8.update



test_libs:
	bazel test //libs/...

test_projects:
	bazel test //projects/...

test_py_calculator:
	echo "TODO"

test_flask_calculator:
	echo "TODO"

test_fastapi_echo:
	bazel test //projects/py_echo_fastapi_app:webapp_test

test_oci_py_helloworld:
	bazel test //projects/py_helloworld_cli_app:test

test_oci_py_helloworld_v2:
	bazel test //projects/py_helloworld_v2_cli_app:test



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

run_oci_py_helloworld_v2:
	#bazel run //projects/py_helloworld_v2_cli_app:hello_world_bin
	bazel build //projects/py_helloworld_v2_cli_app:tarball
	docker load --input `bazel cquery --output=files //projects/py_helloworld_v2_cli_app:tarball`
	docker run --rm local/py_helloworld_v2_cli_app:latest



skaffold_dev_go_devops_cli_app:
	skaffold dev -m go-devops-cli-app-config

skaffold_dev_go_devops_cli_app_debug:
	skaffold dev -m go-devops-cli-app-config -v debug

skaffold_dev_py_devops_fastapi_app:
	skaffold dev -m py-devops-fastapi-app-config



skaffold_build_go_devops_cli_app:
	skaffold build --quiet -m go-devops-cli-app-config

skaffold_build_py_devops_fastapi_app:
	skaffold build -m py-devops-fastapi-app-config



skaffold_run_go_devops_cli_app:
	skaffold run -m go-devops-cli-app-config



skaffold_render_go_devops_cli_app:
	skaffold render -m go-devops-cli-app-config



minikube_start:
	minikube start

minikube_eval:
	echo 'eval $$(minikube -p minikube docker-env)'

minikube_images:
	minikube image ls --format='table'



watch_images:
	# watch -n 5 'clear; docker images'
	watch -n 5 'clear; minikube image ls --format="table" | grep flyr'

watch_k8s:
	watch -n 5 'clear; kubectl get all --all-namespaces'



git_new:
	git fetch --all
	git checkout -b master origin/master

git_push: test
	git push origin `git rev-parse --abbrev-ref HEAD`

# Must have git-extras installed or
# See: https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/How-to-use-the-git-log-graph-command
git_show_tree:
	git show-tree || git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%n' --abbrev-commit --date=relative --branches



# See: https://github.com/bazelbuild/rules_docker#using-with-docker-locally
bazel_query_go_devops_cli_app_artifact:
	bazel cquery projects/go_devops_cli_app:tarball --output starlark --starlark:expr="target.files.to_list()[0].path"
