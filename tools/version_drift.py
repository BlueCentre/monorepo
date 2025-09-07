"""Version Drift Report (Offline)

Parses the central Python dependency declarations (pyproject.toml) and the
corresponding uv.lock file to produce a consolidated view of direct and
indirect dependencies and highlight floating (unpinned) specs.

Scope (Offline Mode Only):
* No network calls; purely file parsing
* Direct dependencies include default + optional groups (tooling,test,scaffolding)
* Lock resolution extracted from uv.lock (which is TOML-ish / actually a lock format)

Output:
* Human-readable table (default)
* JSON via --json flag

Future Enhancements (Not implemented yet):
* Online mode that queries latest versions from PyPI to compute available upgrades
* Severity classification (major/minor/patch drift) when comparing to latest
* CI artifact publishing / historical trends
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Set

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

RE_LOCK_PKG_HEADER = re.compile(r"^#\s+name:\s+(?P<name>[A-Za-z0-9_.-]+)$")
RE_LOCK_VERSION = re.compile(r"^version\s*=\s*\"(?P<ver>[^\"]+)\"$")

@dataclass
class DirectDep:
    name: str
    spec: str  # e.g. ">=1.0.0" or "==2.3.4" or "^1.2"
    groups: Set[str]

@dataclass
class LockedDep:
    name: str
    version: str

@dataclass
class DriftRecord:
    name: str
    spec: Optional[str]
    locked: Optional[str]
    floating: bool  # True if spec not an exact pin (==) or missing


def parse_pyproject(pyproject_path: Path) -> Dict[str, DirectDep]:
    data = tomllib.loads(pyproject_path.read_text())
    tool = data.get("project", {})
    deps: Dict[str, DirectDep] = {}

    def add_dep(line: str, group: str):
        # Accept forms like "pkg", "pkg==1.2.3", "pkg>=1", etc.
        if ";" in line:
            line = line.split(";", 1)[0].strip()
        if not line:
            return
        # Split extras: pkg[extra]==1.2.3
        name_part = line
        spec_part = ""
        for op in ["==", ">=", "<=", "~=", "^", ">", "<"]:
            if op in line:
                name_part, spec_part = line.split(op, 1)
                name_part = name_part.strip()
                spec_part = op + spec_part.strip()
                break
        name = name_part.strip()
        if name.startswith("#"):
            return
        if name not in deps:
            deps[name] = DirectDep(name=name, spec=spec_part or "", groups=set())
        deps[name].groups.add(group)

    for dep in tool.get("dependencies", []) or []:
        add_dep(dep, "default")

    opt = tool.get("optional-dependencies", {}) or {}
    for group, group_deps in opt.items():
        for dep in group_deps:
            add_dep(dep, group)

    return deps


def parse_uv_lock(lock_path: Path) -> Dict[str, LockedDep]:
    # uv.lock is TOML but with repeated sections; easier to regex scan.
    locked: Dict[str, LockedDep] = {}
    current: Optional[str] = None
    for line in lock_path.read_text().splitlines():
        line = line.rstrip()
        m = RE_LOCK_PKG_HEADER.match(line)
        if m:
            current = m.group("name").lower()
            continue
        if current:
            mv = RE_LOCK_VERSION.match(line)
            if mv:
                locked[current] = LockedDep(name=current, version=mv.group("ver"))
                current = None
    return locked


def build_drift_records(direct: Dict[str, DirectDep], locked: Dict[str, LockedDep]) -> List[DriftRecord]:
    records: List[DriftRecord] = []
    all_names = set(n.lower() for n in direct) | set(locked)
    for name in sorted(all_names):
        d = direct.get(name) or direct.get(name.capitalize())  # simple fallback
        locked_dep = locked.get(name)
        spec = d.spec if d else None
        floating = True
        if spec and spec.startswith("=="):
            floating = False
        if spec == "":  # no spec provided -> floating
            floating = True
        records.append(
            DriftRecord(
                name=name,
                spec=spec,
                locked=locked_dep.version if locked_dep else None,
                floating=floating,
            )
        )
    return records


def render_table(records: List[DriftRecord]) -> str:
    if not records:
        return "No dependency records found."
    name_w = max(len(r.name) for r in records)
    spec_w = max(len(r.spec or "") for r in records + [DriftRecord(name='', spec='spec', locked=None, floating=True)])
    lock_w = max(len(r.locked or "") for r in records + [DriftRecord(name='', spec=None, locked='locked', floating=True)])
    header = f"{'name'.ljust(name_w)}  {'spec'.ljust(spec_w)}  {'locked'.ljust(lock_w)}  floating"
    sep = "-" * len(header)
    lines = [header, sep]
    for r in records:
        lines.append(
            f"{r.name.ljust(name_w)}  {(r.spec or '').ljust(spec_w)}  {(r.locked or '').ljust(lock_w)}  {str(r.floating)}"
        )
    return "\n".join(lines)


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Offline version drift report")
    parser.add_argument("--json", action="store_true", help="Emit JSON instead of table")
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="Repository root (auto-detected)",
    )
    args = parser.parse_args(argv)

    pyproject = args.root / "third_party/python/pyproject.toml"
    lock = args.root / "third_party/python/uv.lock"
    if not pyproject.exists() or not lock.exists():
        print("Missing pyproject.toml or uv.lock under third_party/python", file=sys.stderr)
        return 1

    direct = parse_pyproject(pyproject)
    locked = parse_uv_lock(lock)
    records = build_drift_records(direct, locked)

    if args.json:
        payload = [r.__dict__ for r in records]
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(render_table(records))
        print(f"Total records: {len(records)}")
        floating = sum(1 for r in records if r.floating)
        print(f"Floating specs: {floating}")
    return 0


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
