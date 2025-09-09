#!/usr/bin/env bash
# Bazel workspace status command for stamping build metadata.
# Outputs stable (prefixed with STABLE_) and volatile key-value pairs consumed
# by stamped rules (genrule, oci_image, etc.).
#
# Stable keys should only change when source control state changes; volatile
# keys may change each invocation (e.g. timestamp, user, host).

set -euo pipefail

git_rev=$(git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)
git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)
git_dirty=clean
if ! git diff --quiet --ignore-submodules HEAD 2>/dev/null; then
  git_dirty=dirty
fi

# Derive version from MODULE.bazel (fallback 0.0.0)
version=$(grep -E 'version *= *"' MODULE.bazel 2>/dev/null | head -1 | sed -E 's/.*version *= *"([^"]+)".*/\1/' || true)
if [[ -z "${version:-}" ]]; then
  version=0.0.0
fi

timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
build_user=${USER:-unknown}
build_host=$(hostname -s 2>/dev/null || echo unknown)

# Stable (deterministic across identical source state)
echo "STABLE_BUILD_SCM_REVISION ${git_rev}"
echo "STABLE_BUILD_SCM_BRANCH ${git_branch}"
echo "STABLE_BUILD_SCM_STATUS ${git_dirty}"
echo "STABLE_BUILD_VERSION ${version}"

# Volatile (may change on each build)
echo "BUILD_TIMESTAMP ${timestamp}"
echo "BUILD_USER ${build_user}"
echo "BUILD_HOST ${build_host}"
