#!/usr/bin/env bash
set -euo pipefail

if ! command -v pre-commit >/dev/null 2>&1; then
  echo "[setup_precommit] Installing pre-commit..." >&2
  pip install pre-commit >/dev/null
fi

echo "[setup_precommit] Installing git hooks..." >&2
pre-commit install
echo "[setup_precommit] Running initial hook run..." >&2
pre-commit run --all-files || true
echo "[setup_precommit] Done. Drift hook active for future commits." >&2
