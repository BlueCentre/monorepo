# Versioning & Release Strategy

This document defines how semantic versions, release workflows, and artifacts are managed in the monorepo. It balances consistency (shared infra/tooling) with flexibility (independent component cadences).

## Goals

| Goal | Description |
|------|-------------|
| Predictability | Consumers can rely on semantic guarantees. |
| Flexibility | Apps, libraries, infra modules may release independently. |
| Low Overhead | Automation-first; minimal manual tagging. |
| Traceability | Every artifact maps to a commit (Git SHA + provenance). |
| Evolution | Supports future multi-channel (stable/next) flows. |

## Component Taxonomy

| Type | Examples | Versioning Mode | Typical Artifact(s) | Release Driver |
|------|----------|----------------|---------------------|----------------|
| Runtime Applications | FastAPI template, Flask app, Go services | App semantic version | Container image, Helm chart values, SBOM | Deployment cadence / roadmap |
| Reusable Libraries | `//libs/py/calculator`, future shared Go libs | Library semantic version | Wheel / sdist (optional), internal Bazel target | Downstream consumer need |
| Templates / Scaffolding | `//tools:new_project`, `projects/template/*` | Template spec version | Git tag + changelog | DX improvements |
| Tooling / Dev Scripts | `tools/version_drift.py`, `annotation_smoke_test` | Unversioned (implicit) | N/A (commit-based) | Opportunistic |
| Infrastructure Modules | Terraform / Pulumi configs | Module semantic version | Module bundle, docs | Platform evolution |
| Documentation Sets | `docs/` | Date + implicit | Site / Markdown | Continuous |

## Semantic Versioning Policy

We follow standard SemVer (MAJOR.MINOR.PATCH) with these clarifications:

* MAJOR: breaking API/contract or destructive infra change requiring manual operator action.
* MINOR: backward-compatible feature addition (new endpoints, flags, module variables).
* PATCH: backward-compatible fixes or performance improvements.
* PRE-RELEASE: `-alpha.N`, `-beta.N`, `-rc.N` allowed ahead of MAJOR/MINOR cut.
* BUILD METADATA: Not published in primary tags; internal builds embed git describe for traceability.

## Version Sources & Stamping

| Source | Mechanism | Usage |
|--------|----------|-------|
| Git Tag (`vX.Y.Z`) | Canonical reference | Release identification |
| `git describe` (via `tools/workspace_status.sh`) | Injected as `STABLE_BUILD_GIT_DESCRIBE` | Non-release build provenance |
| Changelog Fragment | `CHANGELOG/` (future) | Auto-aggregation |

## Multi-Component Version Model

We adopt an **independent versioning** strategy, not a single global version. Each releasable unit owns its semantic version lineage while sharing build infrastructure.

### Identifier Conventions

| Namespace | Tag Pattern | Applies To |
|-----------|-------------|-----------|
| Application | `app/<name>/vX.Y.Z` | Runtime deployables |
| Library | `lib/<name>/vX.Y.Z` | Reusable code libraries |
| Template | `template/<name>/vX.Y.Z` | Copier templates |
| Infra Module | `infra/<module>/vX.Y.Z` | Terraform/Pulumi modules |

This prevents tag collision and accelerates discovery (`git tag -l 'lib/calculator/*'`).

## Release Triggers

| Trigger | Mechanism | Typical Use |
|---------|----------|-------------|
| Manual Tag | Maintainer runs helper script | Ad hoc, urgent fix |
| Conventional Commits Batch | CI aggregates unreleased changes | Routine scheduled release |
| API Change Detection (future) | ABI / route diff tooling | Guard rails for MINOR vs MAJOR |
| Template Diff | Copier template file hash change | Template version bump |

## Workflow Overview (Example: Python Library)

1. Developer merges changes to `main` touching `libs/py/calculator/*`.
2. CI job detects unreleased commits since last tag `lib/calculator/vX.Y.Z`.
3. Computes bump type (conventional commits scan):
   * `feat:` → MINOR
   * `fix:` → PATCH
   * `feat!:`, `BREAKING CHANGE:` → MAJOR
4. Generates new version, updates (or creates) `libs/py/calculator/CHANGELOG.md` entry.
5. Creates git tag `lib/calculator/vX.Y+1.Z`.
6. Optionally builds wheel/sdist and publishes to internal registry (future).
7. Attaches provenance (git SHA, dependency snapshot) to release metadata.

## Workflow Overview (Example: Application Image)

1. Changes merged affecting `projects/py/echo_fastapi_app`.
2. CI builds container: tag with:
   * Semantic: `app/echo_fastapi_app/vA.B.C`
   * Immutable digest tag: `sha-<shortsha>`
   * Optional floating channel: `latest`, `stable`, `next`
3. Pushes to registry (future config): `ghcr.io/bluecentre/echo-fastapi-app:<tag>`
4. Emits SBOM + SLSA provenance (future hardening).

## Changelog Strategy

* Keep per-component changelogs at component root (e.g. `libs/py/calculator/CHANGELOG.md`).
* Auto-generate from commit messages; manual curation allowed for clarity.
* Aggregate release notes across components for milestone rollups (optional).

## Automation Building Blocks (Planned)

| Capability | Tool/Path | Status |
|------------|-----------|--------|
| Commit classification | Python script under `tools/` | Planned |
| Tag orchestration | `tools/release.py` | Planned |
| Changelog generation | `tools/changelog.py` | Planned |
| SBOM generation | `syft` integration | Future |
| Provenance attestation | `slsa-generator` | Future |

## Handling Different Cadences

Independent versioning allows:

* High-churn services to release multiple times per week.
* Stable libraries to release only when changes accumulate.
* Templates to version primarily on additive improvements.

Consumers pin stable library versions (`==`) while applications may reference latest internal build meta for fast iteration.

## Pre-Release & Promotion Flow (Optional Future)

1. Auto-tag pre-release: `app/foo/v1.4.0-rc.1` after feature freeze.
2. Deploy to staging; validate metrics & migrations.
3. Promote by tagging final: `app/foo/v1.4.0` (no rebuild if images are content-addressed).
4. `latest` channel updated atomically.

## Dealing with Breaking Changes

| Scenario | Action |
|----------|--------|
| API removal | MAJOR bump; deprecate one MINOR beforehand when possible |
| DB schema destructive change | Require migration plan & feature flag gating |
| Template refactor altering generated structure | MAJOR template version; migration notes |
| Infra variable rename | MAJOR module bump; alias old -> new for one cycle if feasible |

## Cross-Component Dependencies

Avoid direct semantic coupling where possible. If coupling exists (e.g., app requires lib ≥ X.Y.0):

* Document in consuming component README.
* Optionally maintain a compatibility matrix table referencing minimal versions.

## Version Discovery Commands

```bash
# List latest calculator library tags
git tag -l 'lib/calculator/v*' | sort -V | tail -n 5

# Describe current workspace state (stamping value)
./tools/workspace_status.sh

# List latest FastAPI template versions
git tag -l 'template/template_fastapi_app/v*' | sort -V | tail -n 5
```

## Proposed Helper Scripts (Future)

| Script | Purpose | Key Flags |
|--------|---------|-----------|
| `tools/release.py` | Compute bump + create tag | `--component`, `--dry-run`, `--force-level` |
| `tools/changelog.py` | Generate / update changelog | `--component`, `--since-tag` |
| `tools/list-unreleased.py` | Show unreleased commits | `--component` |

## AI Agent Playbook

| Task | Steps |
|------|-------|
| Propose release | Run unreleased scan → produce bump rationale → open PR with changelog fragment |
| Cut release | Invoke helper script (dry-run first) → push tag → verify CI artifacts |
| Add new component | Decide namespace → add README + (future) CHANGELOG stub → update docs table |
| Breaking change | Add deprecation notice → mark commit with `feat!:` or footer `BREAKING CHANGE:` → justify in PR body |

## Edge Cases

| Case | Policy |
|------|--------|
| Hotfix directly on main after release | Patch bump; annotate PR with `hotfix:` label |
| Revert of released change | New patch version; never delete tags |
| Accidental tag | Create follow-up tag with increment + note; do NOT retcon history |
| Concurrent release attempts | Detect via lock file / tag existence check in script |

## Migration from Ad-Hoc to Formal Releases

1. Inventory existing components & assign namespace classification.
2. Backfill initial `v0.x` tags (or `v1.0.0` if stable) per component.
3. Introduce helper scripts (dry-run only) for 1–2 cycles.
4. Enforce commit message lint (Conventional Commits) for release surfaces.
5. Enable automated tagging in CI post-stabilization.

## FAQs

**Q: Single global version instead?**  
Not chosen—too coarse; forces unrelated bumps and increases coordination cost.

**Q: Can libraries stay untagged?**  
Yes during incubation (`v0.*` phase). Tag once API expectations stabilize.

**Q: How are security fixes communicated?**  
Label PR `security`, note in changelog; patch release prioritized.

**Q: How do templates communicate breaking scaffolding changes?**  
MAJOR template version + upgrade notes section in template README.

## References

* Semantic Versioning: https://semver.org/
* Conventional Commits: https://www.conventionalcommits.org/
* SLSA Provenance: https://slsa.dev/

---
*This strategy is iterative—future automation PRs should update this document as capabilities mature.*
