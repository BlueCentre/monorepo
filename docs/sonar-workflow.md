---
title: Sonar Monorepo Workflow
---

# Sonar Monorepo Workflow

This document explains the standardized multi-project Sonar scanning + coverage pipeline integrated with Bazel.

## Goals

* Single Bazel command to: gather coverage -> normalize artifacts -> run per-project Sonar scans.
* Eliminate duplicated coverage configuration in per-project `sonar-project.properties` files.
* Support local runs (`bazel run`) and CI pipeline usage with minimal environment setup.

## Components

| Area | File / Target | Purpose |
|------|---------------|---------|
| Coverage collection | `bazel coverage //projects/... --combined_report=lcov` | Native Bazel coverage run across all projects |
| Normalization rule | `//tools/coverage:sonar_coverage` | Produces `tools/coverage/lcov.info` and `coverage-python.xml` |
| Orchestration wrapper | `//tools/sonar:coverage_and_scan` | One-shot run: coverage -> normalize -> scan |
| Multi-project scan | `//tools/sonar:scan_all` | Finds per-project property files and invokes `sonar-scanner` |
| Per-project configs | `projects/*/*/sonar-project.properties` | Minimal project identity + source/test layout |

## Generated Artifacts

After a successful run of the wrapper:

```text
tools/coverage/lcov.info             # LCOV unified coverage
tools/coverage/coverage-python.xml   # Python XML coverage (present if Python tests executed)
tools/sonar/last_project_keys.txt    # List of project keys from latest scan_all run
```

These are auto-injected into sonar-scanner invocations; projects no longer embed `sonar.python.coverage.reportPaths`.

## Running Locally

From real workspace root:

```bash
export SONAR_TOKEN=*****   # or place in .env
HOST_WORKSPACE=$PWD bazel run //tools/sonar:coverage_and_scan
```
Optional extra Sonar parameters (branch, PR, etc.):

```bash
HOST_WORKSPACE=$PWD bazel run //tools/sonar:coverage_and_scan -- \
  -Dsonar.branch.name=my-feature
```

## .env Support

If a `.env` file exists at the workspace root it is sourced automatically by `coverage_and_scan.sh`. Supported common keys:

```bash
SONAR_TOKEN=*****
SONAR_SCANNER=/custom/path/sonar-scanner
SONAR_QG_STRICT_LIST=BlueCentre_monorepo_helloworld_py_app
```

## Skip Behavior

* If `sonar-scanner` binary is not found, scans are skipped with a notice.
* If `SONAR_TOKEN` is missing, scans are skipped (coverage still produced).
* Quality gate waiting is only attempted when `SONAR_QG_WAIT` is exported.

## Strict Quality Gate Overrides

Provide a comma list in `SONAR_QG_STRICT_LIST` to inject additional dynamic params (placeholder logic in `scan_all.sh`). Example:

```bash
export SONAR_QG_STRICT_LIST=BlueCentre_monorepo_calculator_cli_py_app
```

## Quality Gate Polling (Optional)

Set `SONAR_QG_WAIT=1` (and ensure `SONAR_TOKEN` is valid) to have the wrapper call `tools/sonar/quality_gate_wait.sh` after scans.

Environment overrides:

| Variable | Default | Purpose |
|----------|---------|---------|
| `SONAR_ORG` | bluecentre | SonarCloud organization key |
| `SONAR_HOST_URL` | https://sonarcloud.io | Host base URL |
| `POLL_INTERVAL` | 10 | Seconds between status polls |
| `TIMEOUT_SECONDS` | 600 | Max total wait time |
| `KEYS_FILE` | tools/sonar/last_project_keys.txt | Project key list source |

## CI Integration (CircleCI Example)

```yaml
version: 2.1
orbs:
  python: circleci/python@2.1
jobs:
  sonar_scan:
    docker:
      - image: cimg/base:stable
    resource_class: medium
    environment:
      BAZELISK_GITHUB_TOKEN: << pipeline.parameters.github_token >>
    steps:
      - checkout
      - run: sudo apt-get update && sudo apt-get install -y curl unzip
      - run: |
          curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64 -o bazel
          chmod +x bazel && sudo mv bazel /usr/local/bin/
      - run: |
          curl -sSLo sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
          unzip -q sonar-scanner.zip
          sudo mv sonar-scanner-*/ /opt/sonar-scanner
          echo 'export PATH=/opt/sonar-scanner/bin:$PATH' >> $BASH_ENV
          echo 'export HOST_WORKSPACE=$PWD' >> $BASH_ENV
          echo 'export SONAR_TOKEN=$SONAR_TOKEN' >> $BASH_ENV
      - run: source $BASH_ENV && bazel run //tools/sonar:coverage_and_scan --config=ci
workflows:
  sonar:
    jobs:
      - sonar_scan:
          context: sonar # holds SONAR_TOKEN secret
```

Notes:

* Use a CircleCI context (or other secret store) to inject `SONAR_TOKEN`.
* Set `HOST_WORKSPACE=$PWD` before `bazel run` inside CI to avoid execroot recursion issues.

## Adding a New Project

1. Create minimal `sonar-project.properties` with key + inclusions.
2. Add `exports_files(["sonar-project.properties"])` to that project's `BUILD.bazel` so the scanner wrapper can depend on it.
3. Run the wrapper; coverage injection handles reports automatically.

## Troubleshooting

| Symptom | Likely Cause | Action |
|---------|--------------|--------|
| Scans skipped (message about token) | Missing `SONAR_TOKEN` | Export token or add to `.env` |
| 401 errors from Sonar | Invalid/expired token | Regenerate token on SonarCloud |
| No per-project files found | Missing `exports_files` or wrong directory | Add `exports_files` or verify path |
| Coverage files missing | No tests executed | Ensure test targets exist or accept zero coverage |

## Design Rationale

Centralizing coverage artifact injection avoids path drift and reduces maintenance per project. The wrapper isolates Bazel sandbox constraints via `HOST_WORKSPACE`, enabling reproducible local and CI usage.
