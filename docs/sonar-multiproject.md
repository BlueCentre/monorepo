# Sonar Multi-Project Strategy

This document describes how we decompose the monorepo into multiple Sonar projects while still supporting a consolidated root scan.

## Goals

- Per-application quality gates (owners can react fast)
- Root aggregate view for cross-cutting concerns
- Re-use Bazel coverage artifacts to avoid duplicate work

## Layout

Per-project `sonar-project.properties` files live alongside each app (templates excluded to avoid duplication noise):

```text
projects/
  py/
    helloworld_py_app/sonar-project.properties
    calculator_cli_py_app/sonar-project.properties
  template/
    template_fastapi_app/sonar-project.properties
```

The root `sonar-project.properties` offers a holistic scan (all languages, security hotspots, duplication, etc.).

## Coverage Generation

Use Bazel once, then share outputs. A normalization + (optional) merge step is provided.

```bash
bazel coverage //projects/... --combined_report=lcov
bazel build //tools/coverage:sonar_coverage
# (Optional) merge additional LCOV fragments if you create them:
./tools/coverage/merge_coverage.sh tools/coverage/out/merged.info tools/coverage/out/lcov.info
```

Artifacts after build:

```text
bazel-bin/tools/coverage/out/lcov.info
bazel-bin/tools/coverage/out/coverage-python.xml (if conversion tool available)
```

Alternatively (direct fallback without Bazel):

```bash
coverage run -m pytest projects
coverage xml -o tools/coverage/out/coverage-python.xml
```

## Running Individual Project Scans (Auto-Discovery Preferred)

Preferred scripted approach (excludes templates):

```bash
./tools/sonar/scan_all.sh
```

Manual example (explicit):

```bash
sonar-scanner -Dproject.settings=projects/py/helloworld_py_app/sonar-project.properties
sonar-scanner -Dproject.settings=projects/py/calculator_cli_py_app/sonar-project.properties
```

## Running Aggregate Root Scan

```bash
sonar-scanner   # uses root sonar-project.properties
```

## CI Pattern (Pseudo YAML)

```yaml
steps:
  - run: bazel coverage //projects/... --combined_report=lcov
  - run: bazel build //tools/coverage:sonar_coverage
  - run: ./tools/sonar/scan_all.sh
  - run: sonar-scanner  # root scan last (aggregate, still excludes templates now)
```

## Future Enhancements

- Add Go & Java coverage integration (hooks already stubbed in scripts).
- Introduce consolidated coverage merging for language parity.
- Add script to auto-discover per-project property files (pattern: `**/sonar-project.properties`).
- Parameterize quality gate profiles per project (e.g., stricter for templates).

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| No coverage shown | Missing or mispathed coverage file | Verify `bazel-bin/tools/coverage/out` contents & property paths |
| Duplicate issues | Root + project scanning same path or template code included | Ensure root excludes `projects/template/**` |
| Huge LOC spike | Generated Bazel outputs scanned | Ensure your root exclusions match `bazel-*`, `bazel-bin`, `bazel-out` |
| Converter missing | `lcov_cobertura` not installed | `pip install lcov-cobertura` |

## Rationale

A multi-project breakdown improves signal-to-noise while the root project preserves a holistic risk/security view. Bazel coverage sharing prevents redundant test execution.
