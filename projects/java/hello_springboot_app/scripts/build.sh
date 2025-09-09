#!/usr/bin/env bash

# See:
# - https://skaffold-staging.web.app/docs/pipeline-stages/builders/
# - https://skaffold.dev/docs/builders/builder-types/custom/

set -euo pipefail

echo "===[DEBUG] build.sh==="
echo "IMAGE: ${IMAGE}"
echo "PUSH_IMAGE: ${PUSH_IMAGE}"
echo "BUILD_CONTEXT: ${BUILD_CONTEXT}"
echo "PLATFORMS: ${PLATFORMS}"
echo "SKIP_TEST: ${SKIP_TEST}"
echo "===[DEBUG] build.sh==="

cd "${BUILD_CONTEXT}"

# Optional tests (none defined now, but future-safe)
if [ "${SKIP_TEST:-false}" != "true" ]; then
    bazel test //projects/java/hello_springboot_app/... || echo "(No tests or some failed; continuing for dev)"
fi

echo "Building Spring Boot deploy jar via Bazel"
bazel build //projects/java/hello_springboot_app/src/main/java/hello:app_deploy.jar

# Resolve absolute bazel-bin (do NOT rely on relative paths that differ by CWD)
BAZEL_BIN=$(bazel info bazel-bin)
echo "Detected bazel-bin: $BAZEL_BIN"

APP_OUTPUT_DIR="$BAZEL_BIN/projects/java/hello_springboot_app/src/main/java/hello"

if [ ! -d "$APP_OUTPUT_DIR" ]; then
    echo "ERROR: Expected Bazel output dir not found: $APP_OUTPUT_DIR" >&2
    exit 1
fi

DEPLOY_JAR="$APP_OUTPUT_DIR/app_deploy.jar"
if [ ! -f "$DEPLOY_JAR" ]; then
    echo "ERROR: Expected deploy jar not found: $DEPLOY_JAR" >&2
    exit 1
fi
echo "Using deploy jar: $DEPLOY_JAR"

TMP_DIR=$(mktemp -d)
cp "$DEPLOY_JAR" "$TMP_DIR/app.jar"

cat > "$TMP_DIR/Dockerfile" <<'EOF'
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY app.jar .
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
EOF

PLATFORM_OPT=""
if [ -n "${PLATFORMS:-}" ]; then
    PLATFORM_OPT="--platform=${PLATFORMS%%,*}" # first platform only for docker driver
fi

echo "Building image ${IMAGE} ${PLATFORM_OPT}"
docker build $PLATFORM_OPT -t "$IMAGE" "$TMP_DIR"

rm -rf "$TMP_DIR"

if ${PUSH_IMAGE}; then
    docker push "$IMAGE"
fi
