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

bazel build //projects/py_devops_fastapi_app:tarball

# TAR_FILE=$(bazel cquery --output=files //projects/go_devops_cli_app:tarball)
# docker load --input ${TAR_FILE}
TAR_PATH="$(bazel info bazel-bin)/projects/py_devops_fastapi_app/tarball"
docker load -i ${TAR_PATH}/tarball.tar
docker tag flyr.io/bazel/py-devops-fastapi-app ${IMAGE}

if ${PUSH_IMAGE}
then
    docker push ${IMAGE}
fi
