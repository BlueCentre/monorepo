# Copier Version Update Guide

Copier is included as a Python dependency under the `scaffolding` optional dependency group in `pyproject.toml`.

## Current Location

```text
third_party/python/pyproject.toml
```

Excerpt:

```toml
[project.optional-dependencies]
scaffolding = [
  "copier==9.10.1",
]
```

## When to Bump Copier

- New features needed for project template generation
- Bug fixes or security updates
- Template compatibility with new Copier behaviors

## Update Steps

1. Edit the Copier pin in the `scaffolding` group of `pyproject.toml`.
1. Regenerate the consolidated export:

  ```bash
  bazel run //third_party/python:requirements_3_11.update
  ```

1. Commit changes:

  ```bash
  git add third_party/python/pyproject.toml third_party/python/uv.lock third_party/python/requirements_lock_3_11.txt
  git commit -m "chore(copier): bump to <new-version>"
  ```

1. (Optional) Run drift check locally (CI will also run this if configured):

  ```bash
  third_party/python/drift_check.sh
  ```

## Validation

After updating Copier:
- Run the project generator list command:

  ```bash
  bazel run //tools:new_project -- --list-templates
  ```

- Perform a dry-run generation for at least one template:

  ```bash
  bazel run //tools:new_project -- \
    --language python --project-type fastapi \
    --project-name sample_api --dry-run
  ```

## Rollback Procedure

If issues arise:
1. Revert the version change in `pyproject.toml`.
1. Re-run the update script and commit the reverted lock file.

## Notes

- We maintain a single exported lock file (`requirements_lock_3_11.txt`). No multi-version copies are produced.
- Keep the version **pinned** (exact `==`) to ensure reproducibility and predictable template behavior.
- If Copier introduces breaking changes, consider testing in a feature branch before landing on main.
