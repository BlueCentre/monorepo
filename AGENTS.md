# Project Overview

This is a monorepo designed to develop and showcase monorepo patterns and provide blueprints for rapid application development across multiple programming languages. It emphasizes efficient, hermetic, and repeatable builds using Bazel, and facilitates continuous development and integration workflows.

**Key Technologies:**

*   **Build System:** Bazel (primary build tool, managing dependencies via `MODULE.bazel` and `WORKSPACE.bzlmod`).
*   **Languages:** Supports Python, Java (Spring Boot), and Go applications.
*   **Continuous Development:** Skaffold for local development and deployment to Kubernetes.
*   **Continuous Integration:** CircleCI for automated builds and tests, leveraging Bazel and BuildBuddy for remote execution/caching.
*   **Infrastructure as Code (IaC):** Includes configurations for Terraform and Pulumi.

# Building and Running

This project primarily uses Bazel for building and testing, and Skaffold for local continuous development.

## Prerequisites

*   Bazelisk (as `bazel`)
*   Skaffold
*   Minikube (for local Kubernetes development)

## Getting Started

1.  **Clone the repository.**
2.  **Run the quickstart script:**
    ```bash
    make quickstart
    ```
    This command is expected to set up the local environment.
3.  **Initialize Minikube's Docker environment:**
    ```bash
    eval $(minikube -p minikube docker-env)
    ```

## Building with Bazel

To build all targets in the monorepo:

```bash
bazel build //...
```

To run all tests:

```bash
bazel test //...
```

For specific Java projects, the Java language and runtime versions are configured to use Java 11.

## Local Development with Skaffold

Skaffold is configured for continuous development, automatically building and deploying changes to a local Kubernetes cluster. Refer to the `skaffold.yaml` file for specific configurations, which include `pulumi_dev_local` and `projects/template/template_fastapi_app`.

# Development Conventions

*   **Bazel-centric Builds:** All projects within the monorepo are built and tested using Bazel, ensuring consistency and efficiency.
*   **Dependency Management:** External dependencies are managed through Bazel's Bzlmod (`MODULE.bazel`) and legacy `WORKSPACE.bzlmod` for backward compatibility.
*   **Polyglot Support:** The monorepo is designed to accommodate multiple programming languages, with specific rules and toolchains configured for Python (supporting multiple versions) and Java.
*   **Containerization:** Projects are set up to be containerized, with `pkg_tar` rules used for creating application archives, indicating a path towards Docker image creation.
*   **CI/CD Integration:** CircleCI pipelines are configured to automatically build and test changes using Bazel, integrating with BuildBuddy for remote execution and caching to speed up CI workflows.
*   **Roadmap Management:** The project roadmap is managed and tracked using GitHub Projects.
    *   **Tracking:** Individual roadmap items are represented as GitHub Issues within the `BlueCentre/monorepo` repository and linked to the "monorepo project".
    *   **Labeling:** Issues are categorized using labels to provide clarity and facilitate filtering. Common labels include:
        *   `enhancement`: For new features or improvements.
        *   `bug`: For defects or errors.
        *   `documentation`: For updates or creation of documentation.
        *   `dependencies`: For tasks related to managing project dependencies.
        *   `roadmap`: A general label applied to all issues that are part of the official roadmap.
    *   **Tools:** The `gh` CLI (GitHub Command Line Interface) is the primary tool for interacting with the GitHub Project and issues.
    *   **For AI Agents & Contributors:**
        *   When proposing new roadmap items, please create a new issue in the `BlueCentre/monorepo` repository, provide a clear title and detailed description, and apply relevant labels.
        *   Ensure that all roadmap-related issues are linked to the "monorepo project".
        *   Adhere to the established labeling conventions to maintain consistency and improve discoverability.

---

## Guidance for AI Agents & Automation

This section provides explicit operational heuristics for AI coding agents contributing to the monorepo. Follow these rules before falling back to guesswork.

For release, tagging, and semantic version management guidance see: `docs/versioning-and-release-strategy.md`.

## Core Principles

1. Prefer **Bazel-native** operations (build/test) over direct language tool invocation unless Bazel is blocked (see network constraints in `.github/copilot-instructions.md`).
2. Treat `third_party/python/pyproject.toml` + `uv.lock` as the **single source of truth** for Python tooling and dependencies.
3. Never pin dev tooling (linters, test frameworks) unless adding a documented temporary exception in `docs/tooling-version-policy.md`.
4. Add *observability first*, *enforcement later* (e.g., annotation metrics before failing on missing annotations).
5. Keep modifications **minimal and scoped**—avoid broad reformatting or restructuring unless required.

## Python Dependency & Tooling Workflow

| Task | Action |
|------|--------|
| Add/Update dependency | Edit `third_party/python/pyproject.toml` |
| Sync lock + Bazel export | `bazel run //third_party/python:requirements_3_11.update` |
| Local ephemeral venv (optional) | `./scripts/setup_uv_env.sh --groups tooling,test,scaffolding && source .uv-venv/bin/activate` |
| Check for unintended pins | Inspect `pyproject.toml` for `==` specs outside approved exceptions |

Never edit generated lock exports manually (e.g. `requirements_lock_3_11.txt`).

## Linting & Formatting

Ruff is the canonical linter/formatter. Configuration lives in `[tool.ruff]` inside `pyproject.toml` under `third_party/python/`. Current posture: relaxed rules (annotations not enforced) with metrics collected separately.

Add new rule enforcement incrementally—first measure via smoke tests (see Annotation Observability) then tighten (`select` expansion) with a documented phase plan.

## Observability Tooling

| Capability | Bazel Target | Description | Failure Policy |
|------------|--------------|-------------|----------------|
| Annotation metrics | `//tools:annotation_smoke_test` | Runs `ruff check --select ANN --statistics --exit-zero` to capture counts of missing type annotations | Only fails if ruff execution errors |
| Version drift | `//tools:version_drift_test` | Offline structural validation of `version_drift.py` parsing `pyproject.toml` + `uv.lock` | Fails on parsing/runtime error |

Manual invocation examples:

```bash
bazel test //tools:annotation_smoke_test --test_output=all
python tools/version_drift.py --json | jq '.[:5]'
```

## When Bazel Is Blocked (Network Constraints)

If Bazel cannot download toolchains (documented in `.github/copilot-instructions.md`):

1. Fall back to direct language tooling (Python: `python -m`, Go: `go build`, Java: `javac`).
2. Note limitation explicitly in PR description: "Network access blocked - core build tools unavailable."
3. Avoid introducing Bazel-only structural changes unless they can be validated syntactically (e.g., BUILD file edits).

## Bazel Python Pattern Reference

Typical pattern for an app:

```bazel
py_library(
    name = "app_lib",
    srcs = ["app/app.py"],
    deps = ["//libs/py/calculator:calculator_lib"],
)

py_binary(
    name = "app_bin",
    srcs = ["app/app.py"],
    main = "app.py",
    deps = [":app_lib"],
)

py_test(
    name = "app_test",
    srcs = glob(["tests/*.py"]),
    deps = [":app_lib", "//libs/py/calculator:calculator_lib"],
)
```
Use `glob(["tests/*.py"])` for future-proof test expansion.

## Adding New Observability Checks

1. Create a Python script under `tools/` (keep it self-contained).
2. Add a `py_test` target referencing that script in `tools/BUILD.bazel`.
3. Tag with a semantic label (`lint`, `drift`, `observability`).
4. Update `docs/tooling-version-policy.md` (Observability section) if the tool surfaces ongoing metrics.

## Dev Tool Version Policy

Summarized (full policy in `docs/tooling-version-policy.md`):

* Default: use latest stable (unpinned) for dev-only tooling.
* Any pin requires an Exceptions table entry + tracking issue + removal plan.
* Observability tables list resolved versions—this is not pinning.

## Safe Change Heuristics for Agents

| Scenario | Recommended Action |
|----------|--------------------|
| Introduce test for new Python lib | Add `py_test` near existing BUILD; use glob if adding multiple tests |
| Need to enforce new lint rule | First create smoke test or metrics collection; then phase rule into Ruff config |
| Add dependency for a tool script | Modify `pyproject.toml` and regenerate via uv update target |
| Missing annotation counts rising | Report trend; do not fail builds unless hardening phase approved |
| Unsure about build impact | Run selective `bazel build //path:target` before broad `//...` |

## PR Authoring Notes for Agents

Include in PR body when relevant:

* Rationale for any new observability script
* Confirmation that no dev tool pins were introduced (or documented if so)
* Commands used to validate (`bazel test ...`, `python tools/version_drift.py`)
* Notation of network limitations if Bazel fallback was required

## Anti-Patterns to Avoid

* Bulk reformatting unrelated to the functional change.
* Introducing hard-failing lint rules without prior metrics.
* Adding direct `pip install` steps in project subdirectories (always centralize via uv).
* Duplicating dependency specs in individual project folders.

## Future Expansion Hooks (Reserved)

Planned (do not implement without roadmap issue):

* Trend persistence for annotation metrics.
* Online (PyPI) drift comparison mode.
* Automatic gating on exceeding floating spec thresholds.

---

*This section is maintained to optimize autonomous & semi-autonomous agent contributions. Keep additions concise, actionable, and aligned with repository policies.*
 