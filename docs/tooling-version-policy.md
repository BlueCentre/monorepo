# Tooling Version Policy

## Policy Statement

We default to **latest stable versions** for all developer tooling and Python packages used strictly for development (linting, formatting, testing, project scaffolding). We **do not pin** versions unless there is a *documented, time-bound exception* required to maintain build stability or compatibility.

## Rationale

- Reduces long-term upgrade debt.
- Surfaces breaking changes early while context is fresh.
- Simplifies security patch adoption.
- Aligns with monorepo practice of centralizing and harmonizing tooling.

## Scope

Applies to (non-exhaustive):

- Linters / formatters (e.g. `ruff`)
- Test frameworks and plugins (e.g. `pytest`, `pytest-mypy`)
- Scaffolding / generation tools (e.g. `copier`)
- Documentation tooling

Does **not** mandate unpinning for:

- Runtime library APIs where upstream semver breakages affect production services.
- Transitive constraints enforced by Bazel rules.
- Security-sensitive packages where upstream releases may introduce unstable behavior.

Those cases should be handled via normal dependency governance and may use version ranges.

## Exception Process

If a pin is required:

1. Add the pinned spec (e.g. `ruff==X.Y.Z`) in `third_party/python/pyproject.toml`.
2. Immediately add an entry in the **Exceptions** table below.
3. Include: reason, impact, unblock conditions, target removal date (<=30 days ideally).
4. Create a tracking issue tagged `dependencies` + `roadmap`.
5. Schedule a follow-up to remove the pin.

## Current Exceptions

| Package | Version | Reason | Added | Issue | Target Removal |
|---------|---------|--------|-------|-------|----------------|
| (none)  | —       | —      | —     | —     | —              |

## Operational Notes

- `uv sync` will always resolve latest versions consistent with constraints in `pyproject.toml`.
- CI should *fail fast* only on deterministic incompatibilities (never rely on accidental lock-step).
- If a breaking upstream release lands, prefer a **rapid forward fix** vs. retroactive pin unless outage risk is high.

## Suggested Automation (Future)

- Weekly report of tool version drift vs. NPM/PyPI latest.
- GitHub Action to flag any untracked `==` spec in dev-only groups.
- Optional allow-list for intentionally ranged runtime deps (e.g. `pydantic>=2.3.0`).

## Removal Playbook (When Unpinning)

1. Remove `==` spec.
2. Run: `cd third_party/python && uv sync --group tooling`.
3. Run core hooks: `pre-commit run --all-files`.
4. Update Exceptions table.
5. Close tracking issue.

## Related Files

- `third_party/python/pyproject.toml`
- `.pre-commit-config.yaml`
- `docs/` (this file)

## Observability

Current resolved key dev tooling versions (non-pinned, informational):

| Tool | Resolved Version | Source |
|------|------------------|--------|
| ruff | 0.5.7 | `uv.lock` (resolved from unpinned spec) |

These are NOT pins—listed only to establish the active baseline after the most recent `uv sync`. Changes upstream will naturally update on next sync.

### Added Tooling (Non-Blocking Visibility)

| Capability | Bazel Target | Purpose | Failure Mode |
|------------|--------------|---------|--------------|
| Annotation Smoke Test | `//tools:annotation_smoke_test` | Collects Ruff `ANN*` rule counts (`--exit-zero`) to track annotation adoption before enforcing | Only fails if Ruff invocation itself errors |
| Version Drift Report | `//tools:version_drift_test` (executes `version_drift.py`) | Parses `pyproject.toml` + `uv.lock` offline to list direct + locked deps and flag floating specs | Fails if parsing errors or script crashes |

Run manually:

```bash
# Annotation metrics (human + JSON markers)
bazel test //tools:annotation_smoke_test --test_output=all

# Offline drift table
python tools/version_drift.py

# JSON for automation
python tools/version_drift.py --json | jq '.[:5]'

# Bazel-wrapped drift structural test
bazel test //tools:version_drift_test --test_output=all
```

Future (planned): integrate trend detection + thresholds when moving from observability to enforcement phases.

---

*Maintainers: Keep this file accurate; empty exception table is the desired steady state.*
