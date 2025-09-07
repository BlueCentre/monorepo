#!/usr/bin/env bash
set -euo pipefail

# Regenerate Python lock file using uv (Pattern B migration, simplified single-lock model).
# Source of truth: pyproject.toml (plus uv.lock).
# Output: requirements_lock_3_11.txt (exported hashed requirements) containing base + selected optional groups.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="${BUILD_WORKING_DIRECTORY:-}"
if [ -z "$WORKSPACE_ROOT" ]; then
  CANDIDATE="$SCRIPT_DIR"
  while [ "$CANDIDATE" != "/" ]; do
    if [ -f "$CANDIDATE/MODULE.bazel" ] || [ -f "$CANDIDATE/WORKSPACE" ]; then
      WORKSPACE_ROOT="$CANDIDATE"; break
    fi
    CANDIDATE="$(dirname "$CANDIDATE")"
  done
fi

if [ -z "$WORKSPACE_ROOT" ]; then
  echo "[update_requirements] ERROR: Could not determine workspace root." >&2
  exit 1
fi

cd "$WORKSPACE_ROOT/third_party/python"

if [ ! -f pyproject.toml ]; then
  echo "[update_requirements] ERROR: pyproject.toml not found (expected migration to uv)." >&2
  exit 1
fi

LOCK_311="requirements_lock_3_11.txt"

# Optional dependency groups to include in the exported lock. These correspond to
# [dependency-groups] entries in pyproject.toml. Adjust if groups change.
# NOTE: Do not use the variable name GROUPS (bash special array with numeric group IDs).
DEPS_GROUPS=(tooling test scaffolding)

# Ensure uv is available (lightweight installer). Users may prefer Homebrew: brew install uv
if ! command -v uv >/dev/null 2>&1; then
  echo "[update_requirements] 'uv' not found; installing locally (will place in ~/.local/bin) ..." >&2
  curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || {
    echo "[update_requirements] ERROR: automatic uv install failed. Install manually: brew install uv" >&2
    exit 2
  }
  # Add potential install locations to PATH for this script execution
  export PATH="$HOME/.local/bin:$PATH"
fi

# Create or update uv.lock targeting Python 3.11 (consistent with toolchain)
echo "[update_requirements] Resolving dependencies with uv (Python version from .python-version if present)..." >&2
uv lock

# Export hashed, fully pinned requirements (include transitive deps + selected groups). uv export prints to stdout.
echo "[update_requirements] Exporting hashed requirements (+ groups: ${DEPS_GROUPS[*]}) to $LOCK_311 ..." >&2
EXPORT_CMD=(uv export --format requirements-txt --hashes)
for g in "${DEPS_GROUPS[@]}"; do
  EXPORT_CMD+=(--group "$g")
done
"${EXPORT_CMD[@]}" | grep -v '^\-e \.\s*$' > "$LOCK_311"

# NOTE: We strip the editable '-e .' line because Bazel rules_python cannot install an editable
# requirement under hash-checking mode (pip rejects editable with --hash). Our usage does not
# require installing the monorepo itself as an editable package; dependencies alone suffice.

echo "[update_requirements] Done. Commit pyproject.toml, uv.lock, and $LOCK_311." >&2

