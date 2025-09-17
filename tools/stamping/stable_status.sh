#!/usr/bin/env bash
set -euo pipefail

git_rev="$(git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)"
git_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
git_dirty="clean"
if ! git diff --quiet --ignore-submodules HEAD 2>/dev/null; then
  git_dirty="dirty"
fi

echo "GIT_COMMIT ${git_rev}"
echo "GIT_BRANCH ${git_branch}"
echo "GIT_DIRTY ${git_dirty}"