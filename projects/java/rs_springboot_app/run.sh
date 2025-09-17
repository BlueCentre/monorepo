#!/usr/bin/env sh
set -eu

JAR_PATH="/app/demoapp.jar"
JVM_ARGS_FILE="/jvm/jvm.args"

# Construct args: read jvm.args but drop potentially risky flags for isolation (comment them out in file if needed)
JAVA_CMD_ARGS="$(grep -v '^#' "$JVM_ARGS_FILE" | xargs)"

echo "[run.sh] Launching application with args: $JAVA_CMD_ARGS -cp $JAR_PATH org.springframework.boot.loader.launch.JarLauncher" >&2

java $JAVA_CMD_ARGS -cp "$JAR_PATH" org.springframework.boot.loader.launch.JarLauncher || STATUS=$? || true

STATUS=${STATUS:-0}

if ls /tmp/hs_err_pid*.log >/dev/null 2>&1; then
  echo "[run.sh] Detected JVM crash log(s):" >&2
  for f in /tmp/hs_err_pid*.log; do
    echo "----- BEGIN $f -----" >&2
    # Print only first 400 lines to avoid massive log spam
    head -n 400 "$f" >&2 || true
    echo "----- END $f (truncated) -----" >&2
  done
fi

exit $STATUS
