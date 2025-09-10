#!/usr/bin/env bash
set -euo pipefail

WORKSPACE=${TEST_WORKSPACE:-monorepo}
RUNFILES_ROOT=${TEST_SRCDIR:-""}
if [[ -n "$RUNFILES_ROOT" ]]; then
  CANDIDATE_JAR="$RUNFILES_ROOT/$WORKSPACE/projects/java/rs_springboot_app/demoapp.jar"
  if [[ -f "$CANDIDATE_JAR" ]]; then
    JAR="$CANDIDATE_JAR"
  fi
fi
if [[ -z "${JAR:-}" || ! -f "$JAR" ]]; then
  ALT_JAR="$(dirname "$0")/../../../../bazel-bin/projects/java/rs_springboot_app/demoapp.jar"
  if [[ -f "$ALT_JAR" ]]; then
    JAR="$ALT_JAR"
  fi
fi
if [[ -z "${JAR:-}" || ! -f "$JAR" ]]; then
  echo "FAIL: demoapp.jar not found" >&2
  exit 1
fi

echo "Starting application for readiness functional test..." >&2
java -cp "$JAR" org.springframework.boot.loader.launch.JarLauncher > app.log 2>&1 &
APP_PID=$!
trap 'kill $APP_PID 2>/dev/null || true' EXIT

attempts=40
sleep 2
for i in $(seq 1 $attempts); do
  if curl -sf localhost:8080/actuator/health/readiness >/dev/null 2>&1; then
    echo "Actuator readiness endpoint reachable." >&2
    echo "Functional readiness test passed." >&2
    exit 0
  fi
  if curl -sf localhost:8080/readyz >/dev/null 2>&1; then
    echo "Custom controller readiness endpoint reachable." >&2
    echo "Functional readiness test passed." >&2
    exit 0
  fi
  if ! kill -0 $APP_PID 2>/dev/null; then
    echo "FAIL: process exited before readiness" >&2
    echo "--- app.log (tail) ---" >&2
    tail -n 60 app.log >&2 || true
    exit 1
  fi
  sleep 1
done

echo "FAIL: readiness endpoints not reachable in time" >&2
echo "--- app.log (tail) ---" >&2
tail -n 60 app.log >&2 || true
exit 1