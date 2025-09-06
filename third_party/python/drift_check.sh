#!/usr/bin/env bash
set -euo pipefail

# Drift detection for Python dependency export.
# Re-exports the requirements (including configured groups) and diffs against the committed lock export.
# Fails (non-zero exit) if drift is detected.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

LOCK_FILE="requirements_lock_3_11.txt"
TMP_EXPORT="/tmp/requirements_lock_3_11.reexport.$$"
export UV_CACHE_DIR="${TMPDIR:-/tmp}/uv-cache-${RANDOM}"
mkdir -p "$UV_CACHE_DIR"

if [ ! -f pyproject.toml ]; then
  echo "[drift_check] ERROR: pyproject.toml missing" >&2
  exit 2
fi

if [ ! -f "$LOCK_FILE" ]; then
  echo "[drift_check] ERROR: $LOCK_FILE missing (run update script first)" >&2
  exit 3
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "[drift_check] Installing uv (not found) ..." >&2
  curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || {
    echo "[drift_check] ERROR: uv install failed" >&2
    exit 4
  }
  export PATH="$HOME/.local/bin:$PATH"
fi

# Keep group list in sync with update_requirements.sh (avoid bash special GROUPS variable)
# Groups are defined under [dependency-groups] in pyproject.toml
DEPS_GROUPS=(tooling test scaffolding)
EXPORT_CMD=(uv export --format requirements-txt --hashes)
for g in "${DEPS_GROUPS[@]}"; do
  EXPORT_CMD+=(--group "$g")
done

echo "[drift_check] Re-exporting requirements (groups: ${DEPS_GROUPS[*]}) ..." >&2
"${EXPORT_CMD[@]}" | grep -v '^\-e \.\s*$' > "$TMP_EXPORT"

if diff -u "$LOCK_FILE" "$TMP_EXPORT" > /tmp/requirements_drift.diff 2>/dev/null; then
  echo "[drift_check] OK: No dependency drift detected." >&2
  rm -f "$TMP_EXPORT" /tmp/requirements_drift.diff
  exit 0
else
  echo "[drift_check] Drift detected! See unified diff below:" >&2
  cat /tmp/requirements_drift.diff >&2
  echo >&2
  echo "Run: bazel run //third_party/python:requirements_3_11.update" >&2
  exit 10
fi
