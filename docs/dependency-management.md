# Dependency Management

This document describes how Python dependencies are managed centrally in the monorepo using **uv**, how deterministic lock exports are produced, and the layered drift enforcement mechanisms (local, build, CI).

## Goals

- Single, reproducible lock for Python tooling and runtime dependencies
- Clear separation of categories (runtime, tooling, test, scaffolding)
- Fast, deterministic resolution using `uv`
- Immediate feedback if generated artifacts drift from source of truth

## Canonical Source

All Python dependencies live in:

- `third_party/python/pyproject.toml` (definitions)
- `third_party/python/uv.lock` (resolved lock)

Interpreter version is fixed via `.python-version` (currently `3.11`). Bazel and developers use the same baseline.

## Dependency Groups

`[dependency-groups]` segment in `pyproject.toml` defines non-runtime categories:

- `tooling` – formatters, linters, build helpers
- `test` – pytest stack and supporting libraries
- `scaffolding` – project generator (e.g., Copier) and related utilities

All groups are included in the exported consolidated requirements file to keep the environment hermetic when tests or tooling run under Bazel.

## Update Workflow

1. Edit `third_party/python/pyproject.toml`
1. Regenerate lock + export:

   ```bash
   bazel run //third_party/python:requirements_3_11.update
   ```

1. Commit: `pyproject.toml` `uv.lock` `requirements_lock_3_11.txt`
1. (Optional) Manually verify drift:

   ```bash
   third_party/python/drift_check.sh
   ```

## Export Artifact

The file `third_party/python/requirements_lock_3_11.txt` is generated via `uv export` including all dependency groups. This single hashed export replaces legacy per-interpreter / multi-lock patterns.

## Drift Enforcement Layers

| Layer | Mechanism | Command / Location | Purpose |
|-------|-----------|--------------------|---------|
| Local (optional) | pre-commit hook | `./scripts/setup_precommit.sh` | Stop commits with stale export |
| Build | Bazel test | `bazel test //third_party/python:requirements_drift_test` | Enforce in build graph |
| CI | GitHub Actions | `.github/workflows/python-deps-drift.yml` | Block merges if drifted |

### How Drift is Detected

`third_party/python/drift_check.sh` re-runs `uv export` with the same group set and diffs the result against the committed `requirements_lock_3_11.txt`. Any difference (ignoring expected metadata noise) fails the script.

### Typical Failure & Remediation

1. Modify `pyproject.toml`
1. CI / pre-commit fails showing a diff
1. Regenerate:

   ```bash
   bazel run //third_party/python:requirements_3_11.update
   ```

1. Re-commit updated artifacts

### Copier Version Alignment

When updating the project scaffolding template version, adjust the `copier` (and related tooling) pin under the `scaffolding` group in `pyproject.toml`, then follow the update workflow.

## FAQ

**Q: Why include tooling & test deps in the export?**  
A: Bazel actions that run tests or formatters need deterministic wheels. Including groups prevents hidden dependency drift.

**Q: Can we support multiple Python versions?**  
A: The current strategy optimizes for a single enforced interpreter. Multi-version support would require either matrix exports or per-version lock layering; not implemented to reduce complexity.

**Q: Do I run `uv pip install` locally?**  
A: Prefer `uv sync` with a managed virtualenv. Use the helper script:

```bash
./scripts/setup_uv_env.sh --groups tooling,test,scaffolding
source .uv-venv/bin/activate
```

To reproduce the exact Bazel hashed environment (rarely needed):

```bash
uv venv .venv && . .venv/bin/activate
uv pip install -r third_party/python/requirements_lock_3_11.txt --no-deps
```

## Related Files

- `third_party/python/pyproject.toml`
- `third_party/python/uv.lock`
- `third_party/python/requirements_lock_3_11.txt`
- `third_party/python/update_requirements.sh`
- `third_party/python/drift_check.sh`
- `.github/workflows/python-deps-drift.yml`
- `.pre-commit-config.yaml`
- `scripts/setup_precommit.sh`

## See Also

- Root README summary section (links here)
- `third_party/python/COPIER_UPDATE.md` for template-specific guidance
