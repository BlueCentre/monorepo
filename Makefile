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
query: bazel_query_all
	# bazel query //...

.PHONY: build
build: build_all
	# bazel build //...

.PHONY: build_remote
build_remote: build_all_remote
	# bazel build //... --config=remote

.PHONY: test
test: test_all
	# bazel test //...

.PHONY: test_remote
test_remote: test_all_remote
	# bazel test //... --config=remote

.PHONY: clean
clean: bazel_clean docker_clean
	###########################################################################
	# Cleaned:
	# - bazel build artifacts (prefix: bazel-*)
	# - docker build images (prefix: bazel/*)
	###########################################################################

.PHONY: update
update: update_python_requirements update_maven_pojo update_maven_springboot update_rules_pkg_fixes
	###########################################################################
	# Ran updates...
	# - update_aspect_bazelrc [x]
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
	bazel run @unpinned_maven_springboot//:pin
	# To repin everything:
	# REPIN=1 bazel run @unpinned_maven_springboot//:pin
	# To only repin rules_jvm_external:
	# RULES_JVM_EXTERNAL_REPIN=1 bazel run @unpinned_maven_springboot//:pin

update_rules_pkg_fixes:
	bazel run //bazel/fixes:requirements.update



#
# MAIN MAKEFILE TARGETS SECTION
#

# dev_base_fastapi_app: skaffold_dev_base_fastapi_app
#	# ##########################################################################
#	# Default: Skaffold
#	# ##########################################################################

dev_devops_fastapi_app: skaffold_dev_devops_fastapi_app
	###########################################################################
	# Default: Skaffold
	###########################################################################

dev_devops_go_app: skaffold_dev_devops_go_app
	###########################################################################
	# Default: Skaffold
	###########################################################################

dev_devops_go_app_debug: skaffold_dev_devops_go_app_debug
	###########################################################################
	# Default: Skaffold
	###########################################################################

dev_hello_springboot_app: skaffold_dev_hello_springboot_app
	###########################################################################
	# Default: Skaffold
	###########################################################################



build_all: bazel_build
	###########################################################################
	# Default: Bazel
	###########################################################################

build_all_remote: bazel_build_remote
	###########################################################################
	# Default: Bazel + BuildBuddy
	###########################################################################

build_libs: bazel_build_libs
	###########################################################################
	# Default: Bazel
	###########################################################################

build_libs_remote: bazel_build_libs_remote
	###########################################################################
	# Default: Bazel + BuildBuddy
	###########################################################################

build_projects: bazel_build_projects
	###########################################################################
	# Default: Bazel
	###########################################################################

build_projects_remote: bazel_build_projects_remote
	###########################################################################
	# Default: Bazel + BuildBuddy
	###########################################################################

build_devops_fastapi_app: skaffold_build_devops_fastapi_app
	###########################################################################
	# Default: Skaffold
	###########################################################################

build_devops_go_app: skaffold_build_devops_go_app
	###########################################################################
	# Default: Skaffold
	###########################################################################

build_hello_springboot_app: skaffold_build_hello_springboot_app
	###########################################################################
	# Default: Skaffold
	###########################################################################

build_rs_springboot_app: bazel_build_rs_springboot_app
	###########################################################################
	# Default: Bazel
	###########################################################################



test_all: bazel_test
	###########################################################################
	# Default: Bazel
	###########################################################################

test_all_remote: bazel_test_remote
	###########################################################################
	# Default: Bazel
	###########################################################################

test_libs: bazel_test_libs
	###########################################################################
	# Default: Bazel
	###########################################################################

test_projects: bazel_test_projects
	###########################################################################
	# Default: Bazel
	###########################################################################

test_calculator_cli_py_app: bazel_test_calculator_cli_py_app
	###########################################################################
	# Default: Bazel TODO
	###########################################################################

test_calculator_flask_app: bazel_test_calculator_flask_app
	###########################################################################
	# Default: Bazel TODO
	###########################################################################

test_devops_fastapi_app: bazel_test_devops_fastapi_app
	###########################################################################
	# Default: Bazel
	###########################################################################

test_devops_go_app: bazel_test_devops_go_app
	###########################################################################
	# Default: Bazel
	###########################################################################

test_helloworld_py_app: bazel_test_helloworld_py_app
	###########################################################################
	# Default: Bazel
	###########################################################################

test_hello_springboot_app: bazel_test_hello_springboot_app
	###########################################################################
	# Default: Bazel
	###########################################################################

test_rs_springboot_app: bazel_test_rs_springboot_app
	###########################################################################
	# Default: Bazel
	###########################################################################



run_rs_springboot_app: bazel_run_rs_springboot_app
	###########################################################################
	# Default: Bazel
	###########################################################################



#
# BAZEL SECTION
#

# See:
# - https://earthly.dev/blog/build-java-projects-with-bazel/
# - http://www.webgraphviz.com/

bazel_query_all:
	# bazel query --notool_deps --noimplicit_deps "deps(//...)"
	bazel query //...

bazel_query_all_graph:
	# bazel query --notool_deps --noimplicit_deps "deps(//...)" --output=graph
	bazel query //... --output=graph

bazel_query_libs:
	bazel query //libs/...

bazel_query_libs_graph:
	bazel query //libs/... --output=graph

bazel_query_projects:
	bazel query //projects/...

bazel_query_projects_graph:
	bazel query //projects/... --output=graph

bazel_query_maven_pojo:
	###########################################################################
	# Refer to /MODULE.bazel
	###########################################################################
	# bazel query @maven_pojo//:all --output=build
	# bazel query "@maven_pojo//:*"
	bazel query @maven_pojo//...

bazel_query_maven_pojo_outdated:
	bazel run @maven_pojo//:outdated

bazel_query_maven_springboot:
	###########################################################################
	# Refer to /MODULE.bazel
	###########################################################################
	# bazel query @maven_springboot//:all --output=build
	# bazel query @maven_springboot//:org_springframework_boot_spring_boot --output=build
	bazel query @maven_springboot//...

bazel_query_maven_springboot_outdated:
	bazel run @maven_springboot//:outdated

bazel_query_base_fastapi_app:
	bazel query //projects/base/base_fastapi_app/...

bazel_query_devops_fastapi_app:
	bazel query //projects/py/devops_fastapi_app/...

bazel_query_devops_fastapi_app_artifact:
	bazel cquery //projects/py/devops_fastapi_app:tarball --output starlark --starlark:expr="target.files.to_list()[0].path"

bazel_query_devops_go_app:
	bazel query //projects/go/devops_go_app/...

# See: https://github.com/bazelbuild/rules_docker#using-with-docker-locally
bazel_query_devops_go_app_artifact:
	bazel cquery //projects/go/devops_go_app:tarball --output starlark --starlark:expr="target.files.to_list()[0].path"

bazel_query_echo_fastapi_app:
	bazel query //projects/py/echo_fastapi_app/...

bazel_query_helloworld_py_app:
	bazel query //projects/py/helloworld_py_app/...

bazel_query_example1_java_app:
	bazel query //projects/java/example1_java_app/...

bazel_query_example2_java_app:
	bazel query //projects/java/example2_java_app/...

bazel_query_hello_springboot_app:
	bazel query //projects/java/hello_springboot_app/...

bazel_query_hello_springboot_app_graph:
	bazel query //projects/java/hello_springboot_app/... --output=graph

bazel_query_hello_springboot_app_image:
	bazel query //projects/java/hello_springboot_app:app_image --output=build

bazel_query_hello_springboot_app_image_graph:
	bazel query //projects/java/hello_springboot_app:app_image --output=graph

bazel_query_rs_springboot_app:
	bazel query //projects/java/rs_springboot_app/...



bazel_build:
	bazel build //...

bazel_build_remote:
	bazel build //... --config=remote

bazel_build_libs:
	bazel build //libs/...

bazel_build_libs_remote:
	bazel build //libs/... --config=remote

bazel_build_projects:
	bazel build //projects/...

bazel_build_projects_remote:
	bazel build //projects/... --config=remote

bazel_build_base_fastapi_app:
	bazel build //projects/base/base_fastapi_app/...

bazel_build_devops_fastapi_app:
	# bazel build //projects/py/devops_fastapi_app:tarball
	bazel build //projects/py/devops_fastapi_app/...

bazel_build_devops_fastapi_app_remote:
	# bazel build //projects/py/devops_fastapi_app:tarball --config=remote
	bazel build //projects/py/devops_fastapi_app/... --config=remote

bazel_build_devops_go_app:
	# bazel build //projects/go/devops_go_app:tarball
	bazel build //projects/go/devops_go_app/...

bazel_build_echo_fastapi_app:
	bazel build //projects/py/echo_fastapi_app/...

bazel_build_helloworld_py_app:
	bazel build //projects/py/helloworld_py_app/...

bazel_build_example1_java_app:
	bazel build //projects/java/example1_java_app/...

bazel_build_example2_java_app:
	# bazel build //projects/java/example2_java_app:tarball
	bazel build //projects/java/example2_java_app/...

bazel_build_hello_springboot_app:
	# bazel build //projects/java/hello_springboot_app:tarball
	bazel build //projects/java/hello_springboot_app/...

bazel_build_hello_springboot_app_remote:
	# bazel build //projects/java/hello_springboot_app:tarball --config=remote
	bazel build //projects/java/hello_springboot_app/... --config=remote

# See: https://github.com/salesforce/rules_spring/tree/main/springboot#debugging-the-rule-execution
bazel_build_rs_springboot_app:
	# bazel build //projects/java/rs_springboot_app/... --action_env=debug_springboot_rule=1
	bazel build //projects/java/rs_springboot_app/...



bazel_test:
	bazel test //...

bazel_test_remote:
	bazel test //... --config=remote

bazel_test_libs:
	bazel test //libs/...

bazel_test_libs_remote:
	bazel test //libs/... --config=remote

bazel_test_projects:
	bazel test //projects/...

bazel_test_projects_remote:
	bazel test //projects/... --config=remote

bazel_test_base_fastapi_app:
	bazel test //projects/base/base_fastapi_app/...

bazel_test_calculator_cli_py_app:
	# echo "TODO"

bazel_test_calculator_flask_app:
	# echo "TODO"

bazel_test_devops_fastapi_app:
	bazel test //projects/py/devops_fastapi_app/...

bazel_test_devops_fastapi_app_remote:
	bazel test //projects/py/devops_fastapi_app/... --config=remote

bazel_test_devops_go_app:
	bazel test //projects/go/devops_go_app/...

bazel_test_echo_fastapi_app:
	bazel test //projects/py/echo_fastapi_app/...

bazel_test_helloworld_py_app:
	bazel test //projects/py/helloworld_py_app/...

bazel_test_example1_java_app:
	bazel test //projects/java/example1_java_app/...

bazel_test_example2_java_app:
	bazel test //projects/java/example2_java_app/...

bazel_test_hello_springboot_app:
	bazel test //projects/java/hello_springboot_app/...

bazel_test_hello_springboot_app_remote:
	bazel test //projects/java/hello_springboot_app/... --config=remote

bazel_test_rs_springboot_app:
	bazel test //projects/java/rs_springboot_app/...



bazel_run_devops_fastapi_app:
	bazel run //projects/py/devops_fastapi_app:run_bin

bazel_run_devops_go_app:
	bazel run //projects/go/devops_go_app:app_binary

bazel_run_calculator_cli_py_app:
	bazel run //projects/py/calculator_cli_py_app:app_bin

bazel_run_calculator_flask_app:
	bazel run //projects/py/calculator_flask_app:app_bin

bazel_run_echo_fastapi_app:
	bazel run //projects/py/echo_fastapi_app:run_bin

# Simple container app without k8s deployment
bazel_run_helloworld_py_app:
	bazel run //projects/py/helloworld_py_app:hello_world_bin

bazel_run_example1_java_app:
	bazel run //projects/java/example1_java_app:java-maven

bazel_run_example2_java_app:
	bazel run //projects/java/example2_java_app/src/main/java/com/example:JavaLoggingClient

bazel_run_hello_springboot_app:
	# bazel run //projects/java/hello_springboot_app/src/main/java/hello:app
	bazel run //projects/java/hello_springboot_app/src/main/java/hello:projects/java/hello_springboot_app/src/main/java/hello_apprun

bazel_run_rs_springboot_app:
	bazel run //projects/java/rs_springboot_app:projects/java/rs_springboot_app_apprun



bazel_clean:
	bazel clean --async



#
# SKAFFOLD SECTION
#

# skaffold_dev_base_fastapi_app:
# 	skaffold dev -m base-fastapi-app-config

skaffold_dev_devops_go_app:
	skaffold dev -m devops-go-app-config

skaffold_dev_devops_go_app_debug:
	skaffold dev -m devops-go-app-config -v debug

# See: https://github.com/GoogleContainerTools/skaffold/issues/4033
# TODO: bazel support in the skaffold container does not work currtnly so we stick with local skaffold
skaffold_dev_devops_fastapi_app:
	# ./tools/scripts/skaffold_container.sh dev -m devops-fastapi-app-config
	skaffold dev -m devops-fastapi-app-config

skaffold_dev_hello_springboot_app:
	skaffold dev -m hello-springboot-app-config

skaffold_build_devops_go_app:
	skaffold build --quiet -m devops-go-app-config

skaffold_build_devops_fastapi_app:
	skaffold build -m devops-fastapi-app-config

skaffold_build_hello_springboot_app:
	skaffold build -m hello-springboot-app-config

skaffold_run_devops_go_app:
	skaffold run -m devops-go-app-config

skaffold_run_hello_springboot_app:
	skaffold run -m hello-springboot-app-config --tail

skaffold_render_devops_go_app:
	skaffold render -m devops-go-app-config

skaffold_render_devops_fastapi_app:
	skaffold render -m devops-fastapi-app-config

skaffold_render_hello_springboot_app:
	skaffold render -m hello-springboot-app-config



#
# DEBUG SECTION
#

debug_jar_example2_java_app_view: bazel_build_example2_java_app
	# jar -tf bazel-bin/projects/java/example2_java_app/src/main/java/hello/app_deploy.jar
	jar -tf bazel-bin/projects/java/example2_java_app/src/main/java/com/example/JavaLoggingClient_deploy.jar

debug_jar_example2_java_app_run: bazel_build_example2_java_app
	# jar -tf bazel-bin/projects/java/example2_java_app/src/main/java/hello/app_deploy.jar
	java -jar bazel-bin/projects/java/example2_java_app/src/main/java/com/example/JavaLoggingClient_deploy.jar

debug_jar_hello_springboot_app_view: bazel_build_hello_springboot_app
	# jar -tf bazel-bin/projects/java/hello_springboot_app/src/main/java/hello/app_deploy.jar
	jar -tf bazel-bin/projects/java/hello_springboot_app/src/main/java/hello/app.jar

debug_jar_hello_springboot_app_run: bazel_build_hello_springboot_app
	# java -jar bazel-bin/projects/java/hello_springboot_app/src/main/java/hello/app_deploy.jar
	java -jar bazel-bin/projects/java/hello_springboot_app/src/main/java/hello/app.jar



docker_clean:
	./tools/scripts/make_docker_cleanup.sh

docker_load_example2_java_app: build_example2_java_app
	docker load --input $$(bazel cquery --output=files //projects/java/example2_java_app:tarball)

docker_run_example2_java_app: docker_load_example2_java_app
	docker run --rm bazel/example2-java-app:latest

docker_load_hello_springboot_app: build_hello_springboot_app
	docker load --input $$(bazel cquery --output=files //projects/java/hello_springboot_app:tarball)

docker_run_hello_springboot_app: docker_load_hello_springboot_app
	docker run --rm bazel/hello-springboot-app:latest



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
	watch -n 5 'clear; echo "WATCH INFO"; docker images --all --format="table" | grep -v "registry.k8s.io"; docker ps | grep -v "registry.k8s.io"; kubectl get all --all-namespaces | column -t; kubectl get configmaps; helm list'

watch_images_minikube:
	watch -n 5 'clear; echo MINIKUBE; minikube image ls --format="table" | grep bazel'

watch_images_docker:
	watch -n 5 'clear; echo DOCKER; docker images | grep bazel'

watch_k8s_minikube:
	watch -n 5 'clear; echo MINIKUBE; kubectl get all --all-namespaces'

watch_ps_docker:
	watch -n 5 'clear; echo DOCKER; docker ps'



#
# ENVIRONMENT SECTION
#

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


#
# REPO SECTION
#

# Analysis
repo_stats:
	docker run --rm -v "$(PWD):/tmp" aldanial/cloc .

repo_view_tree:
	tree --dirsfirst -F -A .

repo_view_build_tree:
	tree --dirsfirst -F -A -P 'BUILD*' .



git_new:
	git fetch --all
	git checkout -b master origin/master

git_push: test
	git push origin `git rev-parse --abbrev-ref HEAD`

git_log_oneline:
	git log --oneline

# Must have git-extras installed or
# See: https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/How-to-use-the-git-log-graph-command
git_show_tree:
	git show-tree || git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%n' --abbrev-commit --date=relative --branches



# TODO:
# - https://github.com/lucperkins/colossus/blob/main/Makefile
# - https://github.com/kriscfoster/multi-language-bazel-monorepo
