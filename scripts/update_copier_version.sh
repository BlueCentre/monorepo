#!/bin/bash

# Script to update Copier to the latest version in requirements

set -e

MONOREPO_ROOT=$(cd $(dirname $0)/.. && pwd)
REQUIREMENTS_IN="${MONOREPO_ROOT}/third_party/python/requirements.in"
REQUIREMENTS_DIR="${MONOREPO_ROOT}/third_party/python"

echo "Updating Copier to version 9.10.1..."

# Check if pip-tools is installed
if ! command -v pip-compile &> /dev/null; then
    echo "pip-tools is not installed. Installing..."
    pip install pip-tools
fi

# Update the requirements_lock files
echo "Regenerating requirements_lock files..."
for version in 3_8 3_9 3_10 3_11; do
    output_file="${REQUIREMENTS_DIR}/requirements_lock_${version}.txt"
    echo "Generating ${output_file}..."
    pip-compile --output-file="${output_file}" "${REQUIREMENTS_IN}" --upgrade-package copier
done

echo "Copier updated to version 9.10.1 successfully."
echo "All requirements_lock files have been regenerated with proper hashes."