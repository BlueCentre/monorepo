#!/usr/bin/env bash
set -euo pipefail
# scan_all.sh
# Discover per-project sonar-project.properties files (excluding templates) and run sonar-scanner for each.
# Optionally applies quality gate differentiation via environment variables.
# Usage:
#   SONAR_TOKEN=xxx ./tools/sonar/scan_all.sh
# Environment:
#   SONAR_SCANNER (optional path override)
#   SONAR_QG_STRICT_LIST (comma list of projectKeys needing stricter params)
#   SONAR_EXTRA_ARGS (global extra args)

SCANNER=${SONAR_SCANNER:-sonar-scanner}
STRICT_LIST=${SONAR_QG_STRICT_LIST:-}
ROOT_KEY_PREFIX="BlueCentre_monorepo"

# Build associative lookup of strict keys
declare -A STRICT
IFS=',' read -r -a STRICT_ARR <<< "$STRICT_LIST"
for k in "${STRICT_ARR[@]}"; do
  [[ -n "$k" ]] && STRICT[$k]=1 || true
done

# Determine search root (prefer real workspace if provided)
if [[ -n "${HOST_WORKSPACE:-}" && -d "${HOST_WORKSPACE}/projects" ]]; then
  SEARCH_ROOT="${HOST_WORKSPACE}/projects"
else
  SEARCH_ROOT="projects"
  if [[ ! -d "$SEARCH_ROOT" ]]; then
    if [[ -n "${RUNFILES_DIR:-}" && -d "${RUNFILES_DIR}/_main/projects" ]]; then
      SEARCH_ROOT="${RUNFILES_DIR}/_main/projects"
    fi
  fi
fi

# Collect property files excluding template projects
mapfile -t FILES < <(find "$SEARCH_ROOT" -type f -name sonar-project.properties ! -path '*/template/*')

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "[scan_all] No per-project sonar-project.properties files found (search root: $SEARCH_ROOT)." >&2
  exit 0
fi

if ! command -v "$SCANNER" >/dev/null 2>&1; then
  echo "[scan_all] '$SCANNER' not found in PATH; skipping Sonar scans. Install sonar-scanner or set SONAR_SCANNER to proceed." >&2
  exit 0
fi

if [[ -z "${SONAR_TOKEN:-}" ]]; then
  echo "[scan_all] SONAR_TOKEN not set; skipping all Sonar scans (set it in environment or .env)." >&2
  exit 0
fi

EXIT_CODE=0
PROJECT_KEYS_FILE="tools/sonar/last_project_keys.txt"
mkdir -p tools/sonar || true
> "$PROJECT_KEYS_FILE"
for f in "${FILES[@]}"; do
  key=$(grep '^sonar.projectKey=' "$f" | head -n1 | cut -d'=' -f2- || true)
  echo "[scan_all] Scanning $f (projectKey=$key)"
  [[ -n "$key" ]] && echo "$key" >> "$PROJECT_KEYS_FILE"
  EXTRA="${SONAR_EXTRA_ARGS:-}"
  # Auto-detect normalized coverage artifacts (relative to workspace root) and inject if present.
  # We deliberately use -D to override any stale per-project config.
  if [[ -f tools/coverage/lcov.info ]]; then
    EXTRA+=" -Dsonar.javascript.lcov.reportPaths=tools/coverage/lcov.info -Dsonar.typescript.lcov.reportPaths=tools/coverage/lcov.info -Dsonar.python.coverage.reportPaths=tools/coverage/coverage-python.xml"
  elif [[ -f tools/coverage/coverage-python.xml ]]; then
    EXTRA+=" -Dsonar.python.coverage.reportPaths=tools/coverage/coverage-python.xml"
  fi
  if [[ -n "$key" && -n "${STRICT[$key]:-}" ]]; then
    echo "[scan_all] Applying strict quality gate adjustments for $key"
    # Example: treat new code threshold lower or add custom param (placeholder demonstration)
    EXTRA+=" -Dsonar.analysis.buildNumber=$(date +%s)"
  fi
  set +e
  $SCANNER -Dproject.settings="$f" $EXTRA
  rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    echo "[scan_all] Failure scanning $key (rc=$rc)" >&2
    EXIT_CODE=$rc
  fi
done

echo "[scan_all] Wrote project key list to $PROJECT_KEYS_FILE"

# If running under execroot and HOST_WORKSPACE provided, ensure file is mirrored there.
if [[ -n "${HOST_WORKSPACE:-}" && -d "$HOST_WORKSPACE" && ! -f "$HOST_WORKSPACE/$PROJECT_KEYS_FILE" ]]; then
  if [[ -f "$PROJECT_KEYS_FILE" ]]; then
    mkdir -p "$(dirname "$HOST_WORKSPACE/$PROJECT_KEYS_FILE")"
    cp "$PROJECT_KEYS_FILE" "$HOST_WORKSPACE/$PROJECT_KEYS_FILE" || true
    echo "[scan_all] Mirrored project key list to $HOST_WORKSPACE/$PROJECT_KEYS_FILE"
  fi
fi

exit $EXIT_CODE
