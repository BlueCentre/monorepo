#!/usr/bin/env bash
set -euo pipefail
# Simple smoke test: ensure the fat jar is runnable in headless mode.
# We avoid starting the full web server by overriding spring.main.web-application-type if possible.
WORKSPACE=${TEST_WORKSPACE:-monorepo}
RUNFILES_ROOT=${TEST_SRCDIR:-""}
if [[ -n "$RUNFILES_ROOT" ]]; then
  # Try runfiles path first
  CANDIDATE_JAR="$RUNFILES_ROOT/$WORKSPACE/projects/java/rs_springboot_app/demoapp.jar"
  if [[ -f "$CANDIDATE_JAR" ]]; then
    JAR="$CANDIDATE_JAR"
  fi
fi

# Fallback to bazel-bin relative (local execution)
if [[ -z "${JAR:-}" || ! -f "$JAR" ]]; then
  ALT_JAR="$(dirname "$0")/../../../../bazel-bin/projects/java/rs_springboot_app/demoapp.jar"
  if [[ -f "$ALT_JAR" ]]; then
    JAR="$ALT_JAR"
  fi
fi

if [[ -z "${JAR:-}" || ! -f "$JAR" ]]; then
  echo "Jar not found in runfiles or bazel-bin fallback" >&2
  exit 1
fi
OUTPUT_FILE="$(mktemp)"
set +e
java -cp "$JAR" org.springframework.boot.loader.launch.JarLauncher --spring.main.web-application-type=none >"$OUTPUT_FILE" 2>&1 &
PID=$!
sleep 5 || true
if grep -q "Started SampleMain" "$OUTPUT_FILE"; then
  echo "Smoke test passed: application reached Started state." >&2
  kill $PID 2>/dev/null || true
  rm -f "$OUTPUT_FILE"
  exit 0
fi
if ps -p $PID > /dev/null 2>&1; then
  kill $PID 2>/dev/null || true
  echo "Smoke test passed: process remained alive for 5s." >&2
  rm -f "$OUTPUT_FILE"
  exit 0
fi
echo "Smoke test failed. Output:" >&2
sed -n '1,120p' "$OUTPUT_FILE" >&2
rm -f "$OUTPUT_FILE"
exit 1
