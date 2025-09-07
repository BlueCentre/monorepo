## Central Python Dependency Management (uv)

This directory is the single source of truth for Python dependencies used across the monorepo. It adopts the "Pattern B" approach with a unified `pyproject.toml` managed by [uv](https://github.com/astral-sh/uv) and exports a Bazel-consumable lock in hashed `requirements.txt` format.

### Key Files

| File | Purpose |
|------|---------|
| `pyproject.toml` | Declarative dependency specification (base runtime + optional groups) |
| `uv.lock` | uv's full resolution lock (do not hand edit) |
| `requirements_lock_3_11.txt` | Exported, fully hashed requirements consumed by Bazel rules_python |
| `drift_check.sh` | Re-exports and diffs to detect uncommitted drift (used by Bazel test) |
| `update_requirements.sh` | Regenerates `uv.lock` + exported lock for Python 3.11 |

### Dependency Groups

Defined under `[dependency-groups]` in `pyproject.toml` and included in the export:

* `tooling` – linters, formatters, static analysis
* `test` – pytest and test helpers
* `scaffolding` – project generation (Copier)

Add or remove groups ONLY if you also update both `update_requirements.sh` and `drift_check.sh` (the `DEPS_GROUPS` arrays must stay in sync).

### Standard Workflow

1. Edit dependencies:
	```bash
	$EDITOR third_party/python/pyproject.toml
	```
2. Regenerate lock + export:
	```bash
	bazel run //third_party/python:requirements_3_11.update
	```
3. Commit results:
	```bash
	git add third_party/python/pyproject.toml \
			 third_party/python/uv.lock \
			 third_party/python/requirements_lock_3_11.txt
	git commit -m "chore(python): update deps"
	```
4. CI / local validation:
	```bash
	bazel test //third_party/python:requirements_drift_test
	```

### Local Virtual Environment (uv-first)

For ad‑hoc local development (outside Bazel hermetic execution) use `uv` directly:

```bash
cd third_party/python
uv venv .venv              # create isolated env (Python 3.11 by default)
. .venv/bin/activate
uv sync --all-extras       # installs base + groups; or use explicit: --group tooling --group test

# Or reproduce exact Bazel environment from export:
uv pip install -r requirements_lock_3_11.txt --no-deps
```

To upgrade a single package (example: fastapi):

```bash
uv add 'fastapi==0.117.*'   # modifies pyproject + lock
bazel run //third_party/python:requirements_3_11.update
```

### Drift Detection

`//third_party/python:requirements_drift_test` runs `drift_check.sh` which:

1. Re-exports with `uv export --hashes --group tooling --group test --group scaffolding`
2. Compares output to committed `requirements_lock_3_11.txt`
3. Fails if there is any diff (exit code 10)

Fix by regenerating the export (see workflow above).

### Why uv?

* Fast resolver + hashing built-in
* Native support for groups (no separate dev requirements file)
* Deterministic lock (`uv.lock`) plus Bazel-compatible export
* Simplifies transition away from pip-tools/pip-compile complexity

### Adding New Runtime Groups

If you introduce e.g. a `docs` group:
1. Add `[dependency-groups].docs = [ ... ]` in `pyproject.toml`
2. Append `docs` to `DEPS_GROUPS` in both scripts
3. Re-run update script & commit

### Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Drift test failing | Export out of date | Run update script & commit |
| Missing dep in Bazel build | Not included in export (group omitted) | Ensure group is in scripts + regenerate |
| Editable `-e .` line appears | uv exporting local project | We filter it out (`grep -v '-e .'`) |
| Version unexpectedly bumped | Transitive update when re-locking | Pin direct dep in `pyproject.toml` |

### Minimal One-Liners

```bash
# Update all + export
bazel run //third_party/python:requirements_3_11.update

# Check drift only
bazel test //third_party/python:requirements_drift_test

# Quick local env (all groups)
uv venv .venv && . .venv/bin/activate && uv sync --all-extras
```

### Future Enhancements

* Multi-Python version resolution (3.11 + 3.12) using separate exports
* Automated renovate-style PRs for outdated dependencies
* Rule generation per group for more granular Bazel deps (if needed)

---
Questions? See `docs/dependency-management.md` for broader context or open an issue.
