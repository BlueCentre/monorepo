#!/bin/bash

# Script to help update the monorepo's requirements

set -e

MONOREPO_ROOT=$(cd $(dirname $0)/../../../.. && pwd)
REQUIREMENTS_IN="${MONOREPO_ROOT}/third_party/python/requirements.in"
REQUIREMENTS_DIR="${MONOREPO_ROOT}/third_party/python"

# Check if pip-tools is installed
if ! command -v pip-compile &> /dev/null; then
    echo "pip-tools is not installed. Installing..."
    pip install pip-tools
fi

# Check if alembic is already in requirements.in
if ! grep -q "^alembic" "${REQUIREMENTS_IN}"; then
    echo "Adding alembic to requirements.in..."
    # Find the line with google-cloud-pubsub and add alembic after it
    sed -i'' -e '/google-cloud-pubsub/a\
alembic' "${REQUIREMENTS_IN}"
else
    echo "alembic is already in requirements.in"
fi

# Remove the TODO comment if it exists
sed -i'' -e '/# TODO: Add alembic here/d' "${REQUIREMENTS_IN}"

# Update the requirements_lock files
echo "Updating requirements_lock files..."
for version in 3_8 3_9 3_10 3_11; do
    output_file="${REQUIREMENTS_DIR}/requirements_lock_${version}.txt"
    echo "Generating ${output_file}..."
    pip-compile --output-file="${output_file}" "${REQUIREMENTS_IN}"
done

echo "Requirements updated successfully."
echo "Now you can run: bazel build //projects/template/template_fastapi_app:run_migrations" 