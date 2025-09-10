#!/usr/bin/env bash
set -euo pipefail

# Simplified image structure test: we receive individual layer tar files as data runfiles.
# We validate that:
#  1. A layer contains meta/info.txt
#  2. A layer contains app/demoapp.jar

RUNFILES_ROOT="${RUNFILES_DIR:-$(pwd)}"

# Determine workspace module path inside TEST_SRCDIR
WS_PREFIX="_main"
if [[ -n "${TEST_SRCDIR:-}" && -d "$TEST_SRCDIR/$WS_PREFIX" ]]; then
  BASE="$TEST_SRCDIR/$WS_PREFIX/projects/java/rs_springboot_app"
else
  BASE="$RUNFILES_ROOT/$WS_PREFIX/projects/java/rs_springboot_app"
fi

declare -a EXPECTED=("metadata_layer_tar.tar" "jvm_args_tar.tar" "demoapp_jar_tar.tar")
TAR_FILES=()
for f in "${EXPECTED[@]}"; do
  CAND="$BASE/$f"
  if [[ -f "$CAND" ]]; then
    TAR_FILES+=("$CAND")
  fi
done

if [[ ${#TAR_FILES[@]} -ne 3 ]]; then
  echo "WARN: Expected 3 layer tars; found ${#TAR_FILES[@]}. Falling back to scan." >&2
  while IFS= read -r f; do
    TAR_FILES+=("$f")
  done < <(find "$RUNFILES_ROOT" -maxdepth 8 -type f -name '*.tar' 2>/dev/null | grep -E '(metadata_layer_tar|jvm_args_tar|demoapp_jar_tar)' || true)
fi

if [[ ${#TAR_FILES[@]} -eq 0 ]]; then
  echo "FAIL: No expected layer tar files found in runfiles" >&2
  exit 1
fi

echo "DEBUG: Using layer tars: ${TAR_FILES[*]}" >&2

FOUND_META=0
FOUND_JAR=0
for layer in "${TAR_FILES[@]}"; do
  if tar -tf "$layer" 2>/dev/null | grep -q 'meta/info.txt'; then
    FOUND_META=1
  fi
  if tar -tf "$layer" 2>/dev/null | grep -q 'app/demoapp.jar'; then
    FOUND_JAR=1
  fi
done

if [[ $FOUND_META -ne 1 ]]; then
  echo "FAIL: metadata file meta/info.txt not found in provided layers" >&2
  exit 1
fi
echo "PASS: metadata layer present" >&2

if [[ $FOUND_JAR -ne 1 ]]; then
  echo "FAIL: app/demoapp.jar not found in provided layers" >&2
  exit 1
fi
echo "PASS: application jar present" >&2

echo "Image structure test (layer tar mode) succeeded" >&2
