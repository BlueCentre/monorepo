# Copier Version Update (uv Migration) - (LEGACY DOC Pending Cleanup)

## Background

We migrated Python dependency management to `uv` (Pattern B). Dependency source of truth is now `third_party/python/pyproject.toml` + `uv.lock`.

## Copier Version Target

We pin `copier==9.10.1` in `pyproject.toml`. To update Copier (or any dependency) in the future, modify the version there and regenerate the lock + exported Bazel-consumed requirements.

## Regenerating Lock & Exported Requirements

Run the Bazel target which wraps the uv workflow:

```bash
bazel run //third_party/python:requirements_3_11.update
```

This will:

1. Ensure `uv` is installed (installs if missing).
2. Resolve dependencies using the Python version specified in `.python-version` (currently `3.11`) and update/create `uv.lock`.
3. Export a hashed pinned set to `requirements_lock_3_11.txt`.
4. (Removed) Legacy multi-version lock copies are no longer produced. We now maintain a single exported file `requirements_lock_3_11.txt` that already includes development groups.

Commit the following after a successful run:

```text
third_party/python/pyproject.toml   (if changed)
third_party/python/uv.lock          (always after resolution changes)
third_party/python/requirements_lock_3_11.txt
third_party/python/requirements_lock_3_11.txt
```

## Verifying Copier Version in Use

Search the generated `requirements_lock_3_11.txt` for the `copier==` line. It should match the version pinned in `pyproject.toml` (scaffolding dependency group).

```bash
grep '^copier==' third_party/python/requirements_lock_3_11.txt
```

## Why uv?

* Faster, parallel dependency resolution.
* Single authoritative dependency declaration (`pyproject.toml`).
* Deterministic lock (`uv.lock`) with reproducible exports (`uv export`).
* Cleaner future path to per-tool optional dependency segmentation.

## Updating Copier in the Future

1. Edit `copier` line in `pyproject.toml` (e.g. bump to `copier==X.Y.Z`).
2. Run `bazel run //third_party/python:requirements_3_11.update`.
3. Commit changed files listed above.

## Legacy Artifacts

Legacy `requirements.in` removed (single lock model complete).

## Troubleshooting

| Issue | Symptom | Resolution |
|-------|---------|-----------|
| Missing uv | Script error: 'uv: command not found' followed by install attempt | Ensure network access; or manually `brew install uv` |
| Network restricted | Lock not updated | Retry in environment with PyPI access |
| Wrong / unexpected Python version | Resolution differences vs CI | Confirm `.python-version` exists and matches expected (3.11). Ensure that Python 3.11 interpreter is installed and discoverable on PATH. Remove any stray per-user uv config overriding version. |

If you change the Python version, update the `.python-version` file and regenerate the lock so that hashes and environment markers reflect the new interpreter baseline.

## Next Steps

This legacy document remains for historical reference. Current process is simplified: single Python baseline (3.11) and single lock export. See `third_party/python/COPIER_UPDATE.md` for the authoritative, up-to-date instructions.
