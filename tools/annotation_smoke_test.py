"""Annotation Smoke Test

Runs Ruff focusing on annotation rules (ANN*) in a non-blocking, observability-only
mode. It always exits successfully but surfaces metrics so we can track drift and
plan phased hardening (see roadmap in pyproject.toml Ruff config comments).

Execution model (under Bazel py_test):
* Invokes `python -m ruff check --select ANN --statistics --exit-zero .`
* Captures stdout and parses counts per code (ANN001, etc.)
* Emits a summarized JSON blob for potential future machine processing.
* Always returns zero exit code unless Ruff invocation itself errors.

Future Enhancements:
* Persist historical metrics (e.g., to a file or external system)
* Add trend detection / thresholds when tightening rules
* Expand to other rule families (e.g., D for docstrings) in later phases
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List

# Regex to capture lines like: "ANN001  123" or "ANN201   4"
STAT_LINE = re.compile(r"^(ANN\d{3})\s+(\d+)\s*$")


def run_ruff_annotation_stats(repo_root: Path) -> Dict[str, int]:
    """Run ruff in annotation-only stats mode and return counts per ANN code.

    We run from the monorepo root to capture global signal. If Ruff exits non-zero
    (which should not happen due to --exit-zero) we raise to fail the test.
    """
    cmd: List[str] = [
        sys.executable,
        "-m",
        "ruff",
        "check",
        "--select",
        "ANN",
        "--statistics",
        "--exit-zero",
        ".",
    ]

    proc = subprocess.run(
        cmd,
        cwd=repo_root,
        text=True,
        capture_output=True,
        check=False,
    )

    if proc.returncode not in (0,):  # Ruff should force 0 via --exit-zero
        print("Unexpected non-zero Ruff return code", proc.returncode, file=sys.stderr)
        print(proc.stderr, file=sys.stderr)
        raise SystemExit(1)

    counts: Dict[str, int] = {}
    for line in proc.stdout.splitlines():
        m = STAT_LINE.match(line.strip())
        if m:
            code, count = m.group(1), int(m.group(2))
            counts[code] = count

    return counts


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    counts = run_ruff_annotation_stats(repo_root)

    summary = {
        "metric": "ruff_annotation_counts",
        "codes": counts,
        "total": sum(counts.values()),
    }

    print("Annotation Smoke Test Metrics (non-blocking):")
    for code in sorted(counts):
        print(f"  {code}: {counts[code]}")
    print(f"  TOTAL: {summary['total']}")

    # Emit JSON (could be captured by CI artifacts in future)
    print("JSON_SUMMARY_BEGIN")
    print(json.dumps(summary, sort_keys=True))
    print("JSON_SUMMARY_END")

    # Always succeed (observability only)
    return 0


if __name__ == "__main__":  # pragma: no cover - entrypoint
    raise SystemExit(main())
