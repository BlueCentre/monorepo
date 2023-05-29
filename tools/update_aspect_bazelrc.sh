#!/bin/bash

# Script to download and update Aspect Bazelrc presets for Bazel 8.x
# Usage: ./tools/update_aspect_bazelrc.sh

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Create directory for bazelrc files if it doesn't exist
BAZELRC_DIR="${WORKSPACE_DIR}/.aspect/bazelrc"
mkdir -p "${BAZELRC_DIR}"

echo "Downloading Aspect bazelrc files to ${BAZELRC_DIR}..."

# List of files to download
BAZELRC_FILES=(
  "bazel6.bazelrc"
  "bazel7.bazelrc"
  "bazel8.bazelrc"
  "convenience.bazelrc"
  "correctness.bazelrc"
  "debug.bazelrc"
  "java.bazelrc"
  "javascript.bazelrc"
  "docker.bazelrc"
  "performance.bazelrc"
)

# Download each file
for file in "${BAZELRC_FILES[@]}"; do
  echo "Downloading ${file}..."
  curl -s -o "${BAZELRC_DIR}/${file}" "https://raw.githubusercontent.com/aspect-build/bazel-lib/main/bazelrc/${file}" || {
    echo "Failed to download ${file}, creating empty file"
    echo "# ${file} - placeholder" > "${BAZELRC_DIR}/${file}"
  }
done

# Create bazel8.bazelrc with appropriate settings if it doesn't exist or is empty
if [ ! -s "${BAZELRC_DIR}/bazel8.bazelrc" ]; then
  echo "Creating minimal bazel8.bazelrc..."
  cat > "${BAZELRC_DIR}/bazel8.bazelrc" << 'EOF'
# Bazel 8.x specific settings
# See https://github.com/bazelbuild/bazel/releases/tag/8.0.0

# Common flags for Bazel 8.x
common --enable_bzlmod

# Incompatible flags that are now enabled by default in Bazel 8.x
build --incompatible_disallow_empty_glob
EOF
fi

echo "Bazelrc files updated successfully!" 