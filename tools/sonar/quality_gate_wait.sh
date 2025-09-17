#!/usr/bin/env bash
set -euo pipefail
# quality_gate_wait.sh
# Poll SonarCloud for quality gate status of project keys previously scanned.
# Inputs:
#   SONAR_TOKEN (required)
#   SONAR_ORG (default: bluecentre)
#   SONAR_HOST_URL (default: https://sonarcloud.io)
#   KEYS_FILE (default: tools/sonar/last_project_keys.txt)
#   POLL_INTERVAL (seconds, default: 10)
#   TIMEOUT_SECONDS (total wait limit, default: 600)

SONAR_TOKEN="${SONAR_TOKEN:-}"
if [[ -z "$SONAR_TOKEN" ]]; then
  echo "[qg-wait] SONAR_TOKEN not set; aborting quality gate wait." >&2
  exit 0
fi

SONAR_ORG="${SONAR_ORG:-bluecentre}"
SONAR_HOST_URL="${SONAR_HOST_URL:-https://sonarcloud.io}"
KEYS_FILE="${KEYS_FILE:-tools/sonar/last_project_keys.txt}"
POLL_INTERVAL="${POLL_INTERVAL:-10}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-600}"

if [[ ! -f "$KEYS_FILE" ]]; then
  echo "[qg-wait] Keys file $KEYS_FILE not found; nothing to check." >&2
  exit 0
fi

mapfile -t KEYS < "$KEYS_FILE"
if [[ ${#KEYS[@]} -eq 0 ]]; then
  echo "[qg-wait] No keys in $KEYS_FILE; nothing to check." >&2
  exit 0
fi

echo "[qg-wait] Monitoring quality gates for ${#KEYS[@]} projects (timeout=${TIMEOUT_SECONDS}s, interval=${POLL_INTERVAL}s)"

start_ts=$(date +%s)
declare -A DONE
EXIT_CODE=0

while true; do
  all_done=true
  for key in "${KEYS[@]}"; do
    if [[ -n "${DONE[$key]:-}" ]]; then
      continue
    fi
    # API: /api/qualitygates/project_status?projectKey=xxx
    http_code=0
    resp=$(curl -s -u "$SONAR_TOKEN:" -w "HTTPSTATUS:%{http_code}" "${SONAR_HOST_URL}/api/qualitygates/project_status?projectKey=${key}" || true)
    http_code=$(echo "$resp" | tr -d '\r' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo "$resp" | sed -e 's/HTTPSTATUS:.*//')
    if [[ "$http_code" == "401" || "$http_code" == "403" ]]; then
      echo "[qg-wait] Unauthorized ($http_code) for $key – aborting early." >&2
      exit 0
    fi
    resp="$body"
    if [[ -z "$resp" ]]; then
      echo "[qg-wait] Empty response for $key (will retry)" >&2
      all_done=false
      continue
    fi
    status=$(echo "$resp" | grep -o '"status":"[A-Z]*"' | head -n1 | cut -d'"' -f4 || true)
    if [[ -z "$status" ]]; then
      echo "[qg-wait] Could not parse status for $key (will retry)" >&2
      all_done=false
      continue
    fi
    case "$status" in
      OK|ERROR|WARN)
        echo "[qg-wait] $key quality gate status: $status"
        DONE[$key]="$status"
        if [[ "$status" == "ERROR" ]]; then
          EXIT_CODE=1
        fi
        ;;
      *)
        echo "[qg-wait] $key status pending ($status)" >&2
        all_done=false
        ;;
    esac
  done
  if $all_done; then
    break
  fi
  now=$(date +%s)
  elapsed=$(( now - start_ts ))
  if (( elapsed >= TIMEOUT_SECONDS )); then
    echo "[qg-wait] Timeout reached (${TIMEOUT_SECONDS}s)" >&2
    EXIT_CODE=2
    break
  fi
  sleep "$POLL_INTERVAL"
done

echo "[qg-wait] Completed. Exit code: $EXIT_CODE"
exit $EXIT_CODE