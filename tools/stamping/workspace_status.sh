#!/usr/bin/env bash
set -euo pipefail

# Volatile build info (changes every build)
echo "BUILD_TIMESTAMP $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "BUILD_USER ${USER:-unknown}" 
echo "BUILD_HOST $(hostname -s 2>/dev/null || echo unknown)"