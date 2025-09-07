# Requirements Update Needed

The Python tooling dependencies have been updated from black/pylint to Ruff, but the lock files need regeneration.

## What Changed
- **Removed**: `black`, `pylint`, `pytest-black`, `pytest-pylint` 
- **Added**: `ruff` (replaces all the above with a single, much faster tool)
- **Kept**: `pytest-mypy` (Ruff doesn't replace type checking)

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

## Benefits
- **Performance**: 10-100x faster linting/formatting
- **Simplicity**: Single tool instead of 4 separate tools
- **Modern**: Industry standard Python tooling
- **Consistency**: Matches the FastAPI template configuration

## Expected File Changes
The lock file will show `ruff` entries instead of:
- `black==25.1.0`
- `pylint==3.3.8` 
- `pytest-black==0.6.0`
- `pytest-pylint==0.21.0`

Delete this file after running the update command.