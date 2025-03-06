#!/bin/bash

# skaffold.sh - Script to run the FastAPI app with Skaffold and Bazel

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Get the root of the monorepo
MONOREPO_ROOT=$(cd "$SCRIPT_DIR"/../../.. && pwd)

function show_help {
  echo "Usage: ./skaffold.sh [OPTIONS] COMMAND [SKAFFOLD_ARGS]"
  echo ""
  echo "A helper script for running the FastAPI app with Skaffold and Bazel."
  echo ""
  echo "Commands:"
  echo "  dev     Development mode with hot reload"
  echo "  run     Deploy once without watching for changes"
  echo "  debug   Debug mode with debugging symbols"
  echo "  delete  Clean up resources"
  echo "  build   Only build the container image with Bazel"
  echo "  help    Show this help message"
  echo ""
  echo "Options:"
  echo "  -n, --namespace NAMESPACE  Kubernetes namespace to use (default: template-fastapi-app)"
  echo "  -c, --context CONTEXT      Kubernetes context to use (default: colima)"
  echo "  -p, --profile PROFILE      Skaffold profile to use (default: dev for dev command)"
  echo ""
  echo "SKAFFOLD_ARGS: Additional arguments passed directly to skaffold (e.g., -v for verbose)"
  echo ""
  echo "Examples:"
  echo "  ./skaffold.sh dev                      # Run in development mode"
  echo "  ./skaffold.sh -n my-namespace run      # Run in a custom namespace"
  echo "  ./skaffold.sh -c docker-desktop dev    # Run with a different Kubernetes context"
  echo "  ./skaffold.sh build                    # Just build the container image with Bazel"
  echo "  ./skaffold.sh run -v debug             # Run with verbose debug output"
  exit 0
}

# Set default values
namespace="default"
context="colima"
command="dev"
profile=""
skaffold_args=()

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--namespace)
      namespace="$2"
      shift 2
      ;;
    -c|--context)
      context="$2"
      shift 2
      ;;
    -p|--profile)
      profile="$2"
      shift 2
      ;;
    help|--help|-h)
      show_help
      ;;
    run|dev|delete|debug|build)
      command="$1"
      shift
      # Collect all remaining arguments as skaffold args
      while [[ $# -gt 0 ]]; do
        skaffold_args+=("$1")
        shift
      done
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Run './skaffold.sh help' for usage information"
      exit 1
      ;;
  esac
done

# Set default profile based on command if not explicitly provided
if [ -z "$profile" ] && [ "$command" != "delete" ] && [ "$command" != "build" ]; then
  profile="$command"
  echo "Using profile: $profile"
fi

# For build command, use Bazel
if [ "$command" == "build" ]; then
  echo "Building with Bazel..."
  # Change to the monorepo root
  cd "$MONOREPO_ROOT"
  
  # Build the tarball with Bazel
  echo "Running: bazel build //projects/template/template_fastapi_app:image_tarball"
  bazel build //projects/template/template_fastapi_app:image_tarball
  
  echo "Creating Docker image from tarball..."
  # Create a temporary directory
  TEMP_DIR=$(mktemp -d)
  # Extract the tarball to the temporary directory
  tar -xf bazel-bin/projects/template/template_fastapi_app/image_tarball.tar -C $TEMP_DIR
  
  # Verify contents were extracted correctly
  echo "Extracted files:"
  ls -la $TEMP_DIR
  
  # If Dockerfile doesn't exist, rename Dockerfile.bazel to Dockerfile
  if [ ! -f "$TEMP_DIR/Dockerfile" ] && [ -f "$TEMP_DIR/Dockerfile.bazel" ]; then
    echo "Renaming Dockerfile.bazel to Dockerfile"
    cp $TEMP_DIR/Dockerfile.bazel $TEMP_DIR/Dockerfile
  fi
  
  # Build the Docker image
  cd $TEMP_DIR
  docker build -t template-fastapi-app:latest .
  
  # Clean up
  cd "$MONOREPO_ROOT"
  rm -rf $TEMP_DIR
  
  echo "Image built successfully with Bazel."
  exit 0
fi

# Make sure we're using the correct context
kubectl config use-context $context

# Create namespace if it doesn't exist
kubectl get namespace $namespace > /dev/null 2>&1 || kubectl create namespace $namespace

# Set the current kubectl context to use our namespace
kubectl config set-context --current --namespace=$namespace

# Run skaffold with the specified command
echo "Running skaffold $command in namespace $namespace with context $context from directory $SCRIPT_DIR"

# Change to the app directory
cd "$SCRIPT_DIR"

profile_flag=""
if [ -n "$profile" ]; then
  profile_flag="--profile=$profile"
fi

case "$command" in
  "dev")
    # Development mode
    skaffold dev $profile_flag "${skaffold_args[@]}"
    ;;
  "run")
    # Just deploy without development mode
    skaffold run $profile_flag "${skaffold_args[@]}"
    ;;
  "delete")
    # Clean up resources
    skaffold delete "${skaffold_args[@]}"
    echo "Do you want to delete the namespace $namespace as well? (y/n)"
    read -r answer
    if [ "$answer" == "y" ]; then
      kubectl delete namespace $namespace
      echo "Namespace $namespace deleted"
    fi
    ;;
  "debug")
    # Debug mode
    skaffold debug $profile_flag "${skaffold_args[@]}"
    ;;
esac

echo "After deployment, run these commands for port forwarding:"
echo "kubectl port-forward service/template-fastapi-app 8000:80 &"
echo "kubectl port-forward service/postgres 5432:5432 &"
echo "kubectl port-forward service/otel-collector 4317:4317 16686:16686 &" 