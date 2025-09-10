#!/usr/bin/env bash
set -euo pipefail

# Basic structure/content validation for the built OCI image.
# The image layout is available in runfiles under the image target tree.

# Locate image root (rules_oci exports an image layout directory in runfiles)
SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNFILES_ROOT="${RUNFILES_DIR:-$(pwd)}"

# Find the image directory (heuristic: look for oci-layout file) starting from runfiles
IMAGE_DIR="$(find "$RUNFILES_ROOT" -type f -name oci-layout -maxdepth 6 2>/dev/null | head -n1 | xargs dirname || true)"

if [[ -z "${IMAGE_DIR}" || ! -f "${IMAGE_DIR}/oci-layout" ]]; then
  echo "ERROR: Could not locate OCI image layout in runfiles" >&2
  exit 1
fi

echo "Found image layout at: ${IMAGE_DIR}" >&2

# Check that our metadata files were included (they should appear as blobs referenced by the config/layers)
# We extract the tar layer that contains meta/ and inspect it.
FOUND_META=0
while IFS= read -r layer; do
  if tar -tf "$layer" 2>/dev/null | grep -q "meta/info.txt"; then
    FOUND_META=1
    break
  fi
done < <(find "$IMAGE_DIR" -type f -name "layer.tar")

if [[ $FOUND_META -ne 1 ]]; then
  echo "FAIL: metadata layer (meta/info.txt) not found in any image layer" >&2
  exit 1
fi

echo "PASS: metadata layer present" >&2

# Verify application jar exists in some layer under app/
FOUND_JAR=0
while IFS= read -r layer; do
  if tar -tf "$layer" 2>/dev/null | grep -q "app/demoapp.jar"; then
    FOUND_JAR=1
    break
  fi
done < <(find "$IMAGE_DIR" -type f -name "layer.tar")

if [[ $FOUND_JAR -ne 1 ]]; then
  echo "FAIL: app/demoapp.jar not found in image layers" >&2
  exit 1
fi

echo "PASS: application jar layer present" >&2

# Optional: check config has user set to nonroot
CONFIG_JSON="$(find "$IMAGE_DIR" -maxdepth 2 -type f -name config.json | head -n1 || true)"
if [[ -f "$CONFIG_JSON" ]]; then
  if grep -q '"User": *"nonroot"' "$CONFIG_JSON"; then
    echo "PASS: config sets user to nonroot" >&2
  else
    echo "WARN: config does not set User to nonroot (expected)" >&2
  fi
else
  echo "WARN: config.json not found for further validation" >&2
fi

echo "Image structure test succeeded" >&2
