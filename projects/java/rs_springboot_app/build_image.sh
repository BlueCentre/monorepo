#!/usr/bin/env bash
set -euo pipefail

# build_image.sh
# Purpose: Load the rs-springboot-app image into the local Docker daemon using the
# Bazel oci_load target. This replaces the earlier (removed) oci_tarball approach.
# The oci_load target already declares repo_tags = ["rs-springboot-app:latest"],
# so after a successful bazel run the image will be available as rs-springboot-app:latest.
#
# Skaffold passes the desired image reference via $IMAGE (and optionally allows
# retagging via SKAFFOLD_DEFAULT_REPO). We ensure the canonical tag exists and
# optionally add an extra dev tag for convenience.

IMAGE_REF="${IMAGE:-rs-springboot-app}"
EXTRA_TAG="${SKAFFOLD_DEFAULT_REPO:+${SKAFFOLD_DEFAULT_REPO}/rs-springboot-app:dev}"

echo "[build_image.sh] Loading image via Bazel (target :demoapp_image_tar) ..."

# Use bazel run so the generated loader script performs docker load internally.
# Force full output download to avoid missing loader script in minimal download mode.
bazel run //projects/java/rs_springboot_app:demoapp_image_tar \
  --remote_download_outputs=all "$@"

echo "[build_image.sh] Verifying image tag 'rs-springboot-app:latest' exists..."
if ! docker image inspect rs-springboot-app:latest > /dev/null 2>&1; then
  echo "[build_image.sh] ERROR: Expected image 'rs-springboot-app:latest' not present after load." >&2
  exit 1
fi

# If Skaffold provided IMAGE (it usually matches artifact image), retag to that if different.
if [[ "${IMAGE_REF}" != "rs-springboot-app:latest" ]]; then
  echo "[build_image.sh] Tagging rs-springboot-app:latest as ${IMAGE_REF}"
  docker tag rs-springboot-app:latest "${IMAGE_REF}" || true
fi

# Optional extra dev tag
if [[ -n "${EXTRA_TAG}" ]]; then
  echo "[build_image.sh] Adding extra dev tag ${EXTRA_TAG} (best-effort)"
  docker tag rs-springboot-app:latest "${EXTRA_TAG}" || true
fi

echo "[build_image.sh] Image load complete. Available tags:"
docker images rs-springboot-app --format '{{.Repository}}:{{.Tag}}' | sed 's/^/  - /'

exit 0
