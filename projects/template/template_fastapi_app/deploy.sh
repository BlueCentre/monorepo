#!/bin/bash

# Script to deploy the FastAPI application and run database migrations
set -e

SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR"

# Parse command line arguments
SKAFFOLD_COMMAND="dev"
SKAFFOLD_ARGS=""

function show_usage {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --run           Run once and exit (default is 'dev' mode which watches for changes)"
  echo "  --debug         Run in debug mode"
  echo "  --skip-migrations  Skip running database migrations"
  echo "  --help          Show this help message"
  exit 1
}

RUN_MIGRATIONS=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --run)
      SKAFFOLD_COMMAND="run"
      shift
      ;;
    --debug)
      SKAFFOLD_COMMAND="debug"
      shift
      ;;
    --skip-migrations)
      RUN_MIGRATIONS=false
      shift
      ;;
    --help)
      show_usage
      ;;
    *)
      SKAFFOLD_ARGS="$SKAFFOLD_ARGS $1"
      shift
      ;;
  esac
done

echo "===== Deploying application with Skaffold ====="
skaffold $SKAFFOLD_COMMAND $SKAFFOLD_ARGS

# Exit early if in dev mode since it's a long-running process
if [ "$SKAFFOLD_COMMAND" = "dev" ]; then
  # In dev mode, Skaffold will keep running
  echo "Skaffold is running in dev mode. Press Ctrl+C to stop."
  echo "To run database migrations, execute: ./scripts/run_db_migrations.sh"
  exit 0
fi

# Run database migrations if enabled
if [ "$RUN_MIGRATIONS" = true ]; then
  echo "===== Running database migrations ====="
  ./scripts/run_db_migrations.sh
fi

echo "===== Deployment completed successfully =====" 