# Requirements Update Needed

The Python tooling dependencies have been updated from black/pylint to Ruff, but the lock files need regeneration.

## What Changed
- **Removed**: `black`, `pylint`, `pytest-black`, `pytest-pylint` 
- **Added**: `ruff` (replaces all the above with a single, much faster tool)
- **Kept**: `pytest-mypy` (Ruff doesn't replace type checking)

## Benefits of This Change
✅ **10-100x faster** linting and formatting cycles  
✅ **Single tool** instead of managing 4 separate tools  
✅ **Modern standard** - Ruff is becoming the Python ecosystem standard  
✅ **Unified config** - All formatting/linting rules in one place  
✅ **Better developer experience** - Faster feedback during development  

## To Update Requirements
Run this command when network access to PyPI is available:

```bash
cd third_party/python
./update_requirements.sh
```

This will:
1. Install `uv` if not available
2. Resolve dependencies from `pyproject.toml`
3. Generate new `requirements_lock_3_11.txt` with Ruff instead of the old tools

## Configuration Applied
- **Line length**: 88 (same as Black)
- **Target version**: Python 3.11
- **Rule sets**: E, F, B, I, N, UP, ANN, S, A, C4, T20, RET, SIM
- **Import sorting**: Black-compatible profile
- **Exclusions**: Bazel directories, test files get relaxed rules

## Files Updated
- `third_party/python/pyproject.toml` - Dependencies and Ruff configuration
- `tools/pytest/defs.bzl` - Removed old linting plugin dependencies  
- `tools/pytest/BUILD.bazel` - Removed .pylintrc export
- `projects/base/base_fastapi_app/README.md` - Updated documentation

## Expected Lock File Changes
The lock file will show `ruff` entries instead of:
- `black==25.1.0`
- `pylint==3.3.8` 
- `pytest-black==0.6.0`
- `pytest-pylint==0.21.0`

Delete this file after running the update command.