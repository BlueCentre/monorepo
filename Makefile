.PHONY: quickstart
quickstart: minikube_start
	# --- QUICKSTART GUIDE ---
	# 1. TODO provide automated required tools check for local development
	#    outside of Cloud Workstations!
	# 2. TODO optionally just automate installing required tools
	# 3. For now, we assume the tools are installed
	# 4. Do not forget to run 'eval $$(minikube -p minikube docker-env)' in your SHELL 
	#    to configure docker to use the minikube docker session

.PHONY: query
query:
	bazel query //...

.PHONY: build
build:
	bazel build //...

.PHONY: build_remote
build_remote:
	bazel build //... --config=remote

.PHONY: test
test:
	bazel test //...

.PHONY: test_remote
test_remote:
	bazel test //... --config=remote

.PHONY: clean
clean:
	bazel clean --async

.PHONY: update
update: update_aspect_bazelrc update_python_requirements update_maven_pojo update_maven_springboot
	###########################################################################
	# Ran updates...
	# - update_aspect_bazelrc
	# - update_python_requirements
	# - update_maven_pojo
	# - update_maven_springboot
	###########################################################################

update_aspect_bazelrc:
	bazel run //.aspect/bazelrc:update_aspect_bazelrc_presets

update_python_requirements:
	bazel run //third_party/python:requirements_3_11.update
	bazel run //third_party/python:requirements_3_10.update
	bazel run //third_party/python:requirements_3_9.update
	bazel run //third_party/python:requirements_3_8.update

update_maven_pojo:
	# bazel run @maven_pojo//:pin
	bazel run @unpinned_maven_pojo//:pin

update_maven_springboot:
	# bazel run @maven//:pin
	bazel run @unpinned_maven_springboot//:pin
	# To repin everything:
	# REPIN=1 bazel run @unpinned_maven_springboot//:pin
	# To only repin rules_jvm_external:
	# RULES_JVM_EXTERNAL_REPIN=1 bazel run @unpinned_maven_springboot//:pin



# See:
# - https://earthly.dev/blog/build-java-projects-with-bazel/
# - http://www.webgraphviz.com/

query_all:
	# bazel query --notool_deps --noimplicit_deps "deps(//...)"
	bazel query //...

query_all_graph:
	# bazel query --notool_deps --noimplicit_deps "deps(//...)" --output=graph
	bazel query //... --output=graph

query_libs:
	bazel query //libs/...

query_libs_graph:
	bazel query //libs/... --output=graph

query_projects:
	bazel query //projects/...

query_projects_graph:
	bazel query //projects/... --output=graph

query_maven_pojo:
	###########################################################################
	# Refer to /MODULE.bazel
	###########################################################################
	# bazel query @maven_pojo//:all --output=build
	# bazel query "@maven_pojo//:*"
	bazel query @maven_pojo//...

query_maven_pojo_outdated:
	bazel run @maven_pojo//:outdated

query_maven_springboot:
	###########################################################################
	# Refer to /MODULE.bazel
	###########################################################################
	# bazel query @maven_springboot//:all --output=build
	# bazel query @maven_springboot//:org_springframework_boot_spring_boot --output=build
	bazel query @maven_springboot//...

query_maven_springboot_outdated:
	bazel run @maven_springboot//:outdated

query_base_fastapi_app:
	bazel query //projects/base_fastapi_app/...

query_devops_fastapi_app:
	bazel query //projects/devops_fastapi_app/...

query_devops_fastapi_app_artifact:
	bazel cquery //projects/devops_fastapi_app:tarball --output starlark --starlark:expr="target.files.to_list()[0].path"

query_devops_go_app:
	bazel query //projects/devops_go_app/...

# See: https://github.com/bazelbuild/rules_docker#using-with-docker-locally
query_devops_go_app_artifact:
	bazel cquery //projects/devops_go_app:tarball --output starlark --starlark:expr="target.files.to_list()[0].path"

query_echo_fastapi_app:
	bazel query //projects/echo_fastapi_app/...

query_helloworld_py_app:
	bazel query //projects/helloworld_py_app/...

query_example1_java_app:
	bazel query //projects/example1_java_app/...

query_example2_java_app:
	bazel query //projects/example2_java_app/...

query_hello_springboot_app:
	bazel query //projects/hello_springboot_app/...

query_hello_springboot_app_graph:
	bazel query //projects/hello_springboot_app/... --output=graph

query_hello_springboot_app_image:
	bazel query //projects/hello_springboot_app:java_image --output=build

query_hello_springboot_app_image_graph:
	bazel query //projects/hello_springboot_app:java_image --output=graph



build_libs:
	bazel build //libs/...

build_libs_remote:
	bazel build //libs/... --config=remote

build_projects:
	bazel build //projects/...

build_projects_remote:
	bazel build //projects/... --config=remote

build_base_fastapi_app:
	bazel build //projects/base_fastapi_app/...

build_devops_fastapi_app:
	bazel build //projects/devops_fastapi_app:tarball

build_devops_fastapi_app_remote:
	bazel build //projects/devops_fastapi_app:tarball --config=remote

build_devops_go_app:
	bazel build //projects/devops_go_app:tarball

build_echo_fastapi_app:
	bazel build //projects/echo_fastapi_app/...

build_helloworld_py_app:
	bazel build //projects/helloworld_py_app/...

build_example1_java_app:
	bazel build //projects/example1_java_app/...

build_example2_java_app:
	bazel build //projects/example2_java_app:tarball

build_hello_springboot_app:
	bazel build //projects/hello_springboot_app:tarball

build_hello_springboot_app_remote:
	bazel build //projects/hello_springboot_app:tarball --config=remote



test_libs:
	bazel test //libs/...

test_libs_remote:
	bazel test //libs/... --config=remote

test_projects:
	bazel test //projects/...

test_projects_remote:
	bazel test //projects/... --config=remote

test_base_fastapi_app:
	bazel test //projects/base_fastapi_app/...

test_devops_fastapi_app:
	bazel test //projects/devops_fastapi_app/...

test_devops_fastapi_app_remote:
	bazel test //projects/devops_fastapi_app/... --config=remote

test_devops_go_app:
	bazel test //projects/devops_go_app/...

test_echo_fastapi_app:
	bazel test //projects/echo_fastapi_app/...

test_helloworld_py_app:
	bazel test //projects/helloworld_py_app/...

test_example1_java_app:
	bazel test //projects/example1_java_app/src/test/...

test_example2_java_app:
	bazel test //projects/example2_java_app/src/test/...

test_hello_springboot_app:
	bazel test //projects/hello_springboot_app/src/test/...

test_py_calculator:
	echo "TODO"

test_flask_calculator:
	echo "TODO"



run_devops_fastapi_app:
	bazel run //projects/devops_fastapi_app:run_bin

run_devops_go_app:
	bazel run //projects/devops_go_app:run_bin

run_py_calculator:
	bazel run //projects/py_calculator_cli_app:app

run_flask_calculator:
	bazel run //projects/py_calculator_flask_app:app

run_echo_fastapi_app:
	bazel run //projects/echo_fastapi_app:run_bin

# Simple container app without k8s deployment
run_helloworld_py_app:
	bazel run //projects/helloworld_py_app:hello_world_bin
	# bazel build //projects/helloworld_py_app:tarball
	# docker load --input `bazel cquery --output=files //projects/helloworld_py_app:tarball`
	# docker run --rm flyr.io/bazel/helloworld_py_app:latest

run_example1_java_app:
	bazel run //projects/example1_java_app:java-maven

run_example2_java_app:
	bazel run //projects/example2_java_app/src/main/java/com/example:JavaLoggingClient

run_hello_springboot_app:
	bazel run //projects/hello_springboot_app/src/main/java/hello:app



# dev_base_fastapi_app:
# 	skaffold dev -m base-fastapi-app-config

dev_devops_go_app:
	skaffold dev -m devops-go-app-config

dev_devops_go_app_debug:
	skaffold dev -m devops-go-app-config -v debug

# See: https://github.com/GoogleContainerTools/skaffold/issues/4033
# TODO: bazel support in the container does not work so we stick with local skaffold
dev_devops_fastapi_app:
	skaffold dev -m devops-fastapi-app-config
	# ./tools/scripts/skaffold_container.sh dev -m devops-fastapi-app-config



skaffold_build_devops_go_app:
	skaffold build --quiet -m devops-go-app-config

skaffold_build_devops_fastapi_app:
	skaffold build -m devops-fastapi-app-config

skaffold_run_devops_go_app:
	skaffold run -m devops-go-app-config

skaffold_render_devops_go_app:
	skaffold render -m devops-go-app-config

skaffold_render_devops_fastapi_app:
	skaffold render -m devops-fastapi-app-config



debug_jar_hello_springboot_app_view:
	jar -tf bazel-bin/projects/hello_springboot_app/src/main/java/hello/app_deploy.jar

debug_jar_hello_springboot_app_run:
	java -jar bazel-bin/projects/hello_springboot_app/src/main/java/hello/app_deploy.jar



docker_clean:
	./tools/scripts/make_docker_cleanup.sh

docker_load_hello_springboot_app:
	docker load --input $$(bazel cquery --output=files //projects/hello_springboot_app:tarball)

docker_run_hello_springboot_app:
	docker run --rm flyr.io/bazel/hello-springboot-app:latest



minikube_start: minikube_eval
	minikube start --mount --mount-string "${HOME}:${HOME}"

minikube_eval:
	#[!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! NOTICE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!]
	# Run this command in your SHELL: eval $$(minikube -p minikube docker-env)
	#[!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! NOTICE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!]

minikube_images:
	minikube image ls --format='table'

# See: https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/
minikube_ingress:
	minikube addons enable ingress



watch:
	watch -n 5 'clear; echo "WATCH INFO"; docker images --all --format="table"; kubectl get all --all-namespaces | column -t; kubectl get configmaps; helm list'

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



# Install tooling for quickstart
# NOTE: Not needed if using Cloud Workstations
env_setup:
	echo "Lets get started!"

env_setup_copier:
	pip install pipx
	pipx install copier

env_setup_bazel:
	echo "Lets build something!"

env_setup_skaffold:
	echo "Continuous Development!"



# Analysis
repo_stats:
	docker run --rm -v "$(PWD):/tmp" aldanial/cloc .



# TODO:
# - https://github.com/lucperkins/colossus/blob/main/Makefile
# - https://github.com/kriscfoster/multi-language-bazel-monorepo
