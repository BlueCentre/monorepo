#!/usr/bin/env bash
# See: https://github.com/GoogleContainerTools/skaffold/issues/4033

# Requires: minikube start --mount --mount-string "${HOME}:${HOME}"

# Preconfigure some environment variables based on defaults. This allows the developer to override environment variables to configure the configuration and cache directories.
SKAFFOLD_CACHE=${SKAFFOLD_CACHE:-$HOME/.skaffold/cache} && \
SKAFFOLD_CONFIG=${SKAFFOLD_CONFIG:-$HOME/.skaffold/config} && \
KUBECONFIG=${KUBECONFIG:-$HOME/.kube/config} && \
MINIKUBE_HOME=${MINIKUBE_HOME:-$HOME/.minikube} && \
MINIKUBE_PROFILE=${MINIKUBE_PROFILE:-minikube} && \

# For minikube it is important to configure the docker client to communicate with the docker engine in minikube.
eval $(minikube -p ${MINIKUBE_PROFILE} docker-env) && \

docker run --rm -it \
--volume ${PWD}:/data \
--volume ${SKAFFOLD_CACHE}:${SKAFFOLD_CACHE} \
--volume ${SKAFFOLD_CONFIG}:${SKAFFOLD_CONFIG} \
--volume ${KUBECONFIG}:${KUBECONFIG}:ro \
--volume ${MINIKUBE_HOME}:${MINIKUBE_HOME}:ro \
--workdir /data \
--env SKAFFOLD_CONFIG=${SKAFFOLD_CONFIG} \
--env KUBECONFIG=${KUBECONFIG} \
--env MINIKUBE_HOME=${MINIKUBE_HOME} \
--env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} \
--env DOCKER_HOST=${DOCKER_HOST} \
--env DOCKER_CERT_PATH=${DOCKER_CERT_PATH} \
--env MINIKUBE_ACTIVE_DOCKERD=${MINIKUBE_ACTIVE_DOCKERD} \
gcr.io/k8s-skaffold/skaffold:latest skaffold $@

