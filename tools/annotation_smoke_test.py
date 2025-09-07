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
from typing import Dict, List, Tuple

# Regex to capture lines like: "ANN001  123" or "ANN201   4"
STAT_LINE = re.compile(r"^(ANN\d{3})\s+(\d+)\s*$")


def run_ruff_annotation_stats(repo_root: Path) -> Tuple[Dict[str, int], bool, str | None]:
    """Run Ruff in annotation-only stats mode.

    Returns (counts, ruff_available, error_message).
    * counts: mapping of ANN code -> count (empty if Ruff unavailable)
    * ruff_available: False if the Ruff module/binary could not be executed
    * error_message: short diagnostic when unavailable or other error encountered

    This function is intentionally defensive: any environment / runfiles issues
    resulting in the Ruff binary not being present should NOT fail this smoke test.
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

    try:
        proc = subprocess.run(
            cmd,
            cwd=repo_root,
            text=True,
            capture_output=True,
            check=False,
        )
    except FileNotFoundError as e:  # Extremely unlikely (python itself missing)
        return {}, False, f"Interpreter missing: {e}"

    # Ruff missing scenario: python -m ruff produced traceback referencing missing bin/ruff
    if proc.returncode != 0:
        stderr_lower = proc.stderr.lower()
        if "filenotfounderror" in stderr_lower and "bin/ruff" in stderr_lower:
            return {}, False, "Ruff binary not found in runfiles (benign)"
        # Any other non-zero: treat as unavailable but record message (still non-blocking)
        return {}, False, f"Ruff invocation failed (rc={proc.returncode})"

    counts: Dict[str, int] = {}
    for line in proc.stdout.splitlines():
        m = STAT_LINE.match(line.strip())
        if m:
            code, count = m.group(1), int(m.group(2))
            counts[code] = count

    return counts, True, None


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    counts, ruff_available, error = run_ruff_annotation_stats(repo_root)

    summary = {
        "metric": "ruff_annotation_counts",
        "codes": counts,
        "total": sum(counts.values()),
        "ruff_available": ruff_available,
    }
    if error:
        summary["error"] = error

    print("Annotation Smoke Test Metrics (non-blocking):")
    if ruff_available:
        for code in sorted(counts):
            print(f"  {code}: {counts[code]}")
        print(f"  TOTAL: {summary['total']}")
    else:
        print("  Ruff unavailable - produced zeroed metrics (this is non-blocking)")
        if error:
            print(f"  Reason: {error}")

    # Emit JSON (could be captured by CI artifacts in future)
    print("JSON_SUMMARY_BEGIN")
    print(json.dumps(summary, sort_keys=True))
    print("JSON_SUMMARY_END")

    # Always succeed (observability only)
    return 0


if __name__ == "__main__":  # pragma: no cover - entrypoint
    raise SystemExit(main())
