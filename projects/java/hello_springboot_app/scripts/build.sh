#!/usr/bin/env bash

# See:
# - https://skaffold-staging.web.app/docs/pipeline-stages/builders/
# - https://skaffold.dev/docs/builders/builder-types/custom/

echo "===[DEBUG] build.sh==="
echo "IMAGE: ${IMAGE}"
echo "PUSH_IMAGE: ${PUSH_IMAGE}"
echo "BUILD_CONTEXT: ${BUILD_CONTEXT}"
echo "PLATFORMS: ${PLATFORMS}"
echo "SKIP_TEST: ${SKIP_TEST}"
echo "===[DEBUG] build.sh==="

# If we can't build, fail quick and exit
bazel build //projects/java/hello_springboot_app:tarball || exit 1

# TAR_FILE=$(bazel cquery --output=files //projects/java/hello_springboot_app:tarball)
# docker load --input ${TAR_FILE}
TAR_PATH="$(bazel info bazel-bin)/projects/java/hello_springboot_app/tarball"
docker load -i ${TAR_PATH}/tarball.tar
docker tag bazel/hello-springboot-app ${IMAGE}

if ${PUSH_IMAGE}
then
    docker push ${IMAGE}
fi
