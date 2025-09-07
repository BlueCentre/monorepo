#!/usr/bin/env bash
set -euo pipefail
# Convenience script to create / refresh a local Python virtual environment using uv
# This is OPTIONAL; Bazel builds are hermetic. Use for ad-hoc iterative dev & editors.
#
# Usage:
#   ./scripts/setup_uv_env.sh [--groups tooling,test] [--python 3.11] [--force]
#
# Default groups: tooling,test,scaffolding
# To install only base runtime deps omit --groups flag.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PY_DIR="$REPO_ROOT/third_party/python"
VENV_DIR="$REPO_ROOT/.uv-venv"
GROUPS="tooling,test,scaffolding"
PY_VERSION=""
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --groups)
      GROUPS="$2"; shift 2;;
    --python)
      PY_VERSION="$2"; shift 2;;
    --force)
      FORCE=1; shift;;
    -h|--help)
      echo "setup_uv_env.sh [--groups g1,g2] [--python 3.11] [--force]"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

if ! command -v uv >/dev/null 2>&1; then
  echo "[uv-env] Installing uv (not found)..." >&2
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if [[ -n "$PY_VERSION" ]]; then
  export UV_PYTHON_PREFERENCE=$PY_VERSION
fi

if [[ -d "$VENV_DIR" && $FORCE -eq 1 ]]; then
  echo "[uv-env] --force specified: removing existing venv" >&2
  rm -rf "$VENV_DIR"
fi

if [[ ! -d "$VENV_DIR" ]]; then
  echo "[uv-env] Creating venv at $VENV_DIR" >&2
  uv venv "$VENV_DIR"
else
  echo "[uv-env] Reusing existing venv at $VENV_DIR" >&2
fi

# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

cd "$PY_DIR"

IFS=',' read -r -a GROUP_ARR <<< "$GROUPS"
EXPORT_GROUP_FLAGS=()
for g in "${GROUP_ARR[@]}"; do
  [[ -n "$g" ]] && EXPORT_GROUP_FLAGS+=(--group "$g")
fi

if [[ ${#EXPORT_GROUP_FLAGS[@]} -gt 0 ]]; then
  echo "[uv-env] Syncing groups: $GROUPS" >&2
  uv sync "${EXPORT_GROUP_FLAGS[@]}"
else
  echo "[uv-env] Syncing base dependencies only" >&2
  uv sync
fi

echo "[uv-env] Done. Activate with: source $VENV_DIR/bin/activate"