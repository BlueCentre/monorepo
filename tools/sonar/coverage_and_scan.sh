#!/usr/bin/env bash
set -euo pipefail
# coverage_and_scan.sh - convenience wrapper (manual)
# 1. Run bazel coverage (user must customize target list if needed)
# 2. Build coverage normalization target
# 3. Run per-project scans (excluding templates)

if ! command -v bazel >/dev/null 2>&1; then
  echo "[coverage_and_scan] bazel not found in PATH" >&2
  exit 1
fi

# Determine workspace root. When invoked via 'bazel run', PWD is an execroot path.
if [[ "$(pwd)" == *"/execroot/_main"* ]]; then
  if [[ -n "${HOST_WORKSPACE:-}" && -d "${HOST_WORKSPACE}" && -f "${HOST_WORKSPACE}/MODULE.bazel" ]]; then
    echo "[coverage_and_scan] Detected execroot; switching to host workspace: $HOST_WORKSPACE"
    cd "$HOST_WORKSPACE"
  else
    echo "[coverage_and_scan] Running inside Bazel execroot. Re-run with HOST_WORKSPACE=<absolute path to checkout> bazel run //tools/sonar:coverage_and_scan" >&2
    echo "[coverage_and_scan] Example: HOST_WORKSPACE=$PWD bazel run //tools/sonar:coverage_and_scan (from real workspace root)" >&2
    exit 2
  fi
fi
echo "[coverage_and_scan] Using workspace root: $(pwd)"

# Auto-load .env if present to pick up SONAR_TOKEN / SONAR_SCANNER overrides.
if [[ -f .env ]]; then
  # shellcheck disable=SC2046,SC1091
  set +u
  # We purposefully source rather than parse to allow user-provided quoting.
  source .env
  set -u
  echo "[coverage_and_scan] Loaded .env"
fi

if [[ -z "${SONAR_TOKEN:-}" ]]; then
  echo "[coverage_and_scan] Warning: SONAR_TOKEN not set (export it or add to .env) – scans will be skipped." >&2
fi

echo "[coverage_and_scan] Running coverage across projects"
bazel coverage //projects/... --combined_report=lcov

echo "[coverage_and_scan] Normalizing coverage"
bazel build //tools/coverage:sonar_coverage

echo "[coverage_and_scan] Executing per-project Sonar scans"
# Allow pass-through extra sonar args after '--'
EXTRA=""
if [[ ${#@} -gt 0 ]]; then
  EXTRA="$*"
fi
SONAR_EXTRA_ARGS="$EXTRA" HOST_WORKSPACE="${HOST_WORKSPACE:-}" SONAR_TOKEN="${SONAR_TOKEN:-}" bazel run //tools/sonar:scan_all

echo "[coverage_and_scan] Done"

if [[ -n "${SONAR_QG_WAIT:-}" ]]; then
  echo "[coverage_and_scan] SONAR_QG_WAIT set; invoking quality gate wait script"
  if [[ -f tools/sonar/quality_gate_wait.sh ]]; then
    bash tools/sonar/quality_gate_wait.sh || echo "[coverage_and_scan] Quality gate wait returned non-zero (continuing)" >&2
  else
    echo "[coverage_and_scan] quality_gate_wait.sh not found; skipping" >&2
  fi
fi
