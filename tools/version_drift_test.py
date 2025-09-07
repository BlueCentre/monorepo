"""Test for version_drift offline script.

Ensures the script produces at least one record and includes required keys
in JSON mode. This is a lightweight structural test (not validating content
correctness in depth) to remain stable across dependency churn.
"""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


def test_version_drift_json():
    repo_root = Path(__file__).resolve().parent.parent
    script = repo_root / "tools" / "version_drift.py"
    proc = subprocess.run(
        [sys.executable, str(script), "--json"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    data = json.loads(proc.stdout)
    assert isinstance(data, list)
    assert data, "Expected at least one dependency record"
    sample = data[0]
    for key in ("name", "spec", "locked", "floating"):
        assert key in sample
