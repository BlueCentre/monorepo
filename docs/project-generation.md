# Project Generation

This document explains how to create new projects in the monorepo using the Bazel-powered Copier project generator.

## Overview

The generator wraps a flexible templating system to create consistent, policy-aligned project skeletons across languages (Python, Go, Java) and application types (web services, CLIs, etc.). It supports both interactive and fully scripted (CI-friendly) usage.

## Command

```bash
bazel run //tools:new_project -- [OPTIONS]
```

If run without options you enter interactive mode and will be prompted for required inputs.

## Supported Languages & Types

| Language | Type | Status | Template | Notes |
|----------|------|--------|----------|-------|
| python | fastapi | available | `template_fastapi_app` | Production FastAPI + Postgres, OTel, Istio, auth |
| python | cli | available | `template_typer_app` | Typer-based CLI skeleton |
| python | flask | placeholder | (none) | Minimal structure until template implemented |
| go | gin | available | `template_gin_app` | Gin HTTP service template |
| go | cli | placeholder | (none) | Planned |
| java | springboot | placeholder | (none) | Planned Spring Boot service |

Legend:

- `available` – Fully implemented template
- `placeholder` – Creates directory layout + basic files only

## Common Flags

| Flag | Description |
|------|-------------|
| `--language <python\|go\|java>` | Target implementation language |
| `--project-type <type>` | Template / project archetype |
| `--project-name <name>` | New project name (sanitized: lowercase, dashes) |
| `--output-dir <path>` | (Optional) Destination path (workspace-relative or absolute). Defaults under `projects/<language>/` |
| `--dry-run` | Preview actions without writing files |
| `--defaults` | Accept template defaults non-interactively |
| `--list-templates` | Show available + placeholder templates |

## Examples

Interactive:

```bash
bazel run //tools:new_project
```text

Non-interactive FastAPI project:

```bash
bazel run //tools:new_project -- \
  --language python \
  --project-type fastapi \
  --project-name awesome_fastapi_app
```

Dry run (see what would be generated):

```bash
bazel run //tools:new_project -- \
  --language go \
  --project-type gin \
  --project-name sample_gin_api \
  --dry-run
```

Specify custom output directory:

```bash
bazel run //tools:new_project -- \
  --language python \
  --project-type cli \
  --project-name tools_cli \
  --output-dir services/tools
```

List templates:

```bash
bazel run //tools:new_project -- --list-templates
```

## Generated Structure (FastAPI Example)

```text
projects/template/awesome_fastapi_app/
├── README.md
├── BUILD.bazel
├── apps/ ...
└── (additional service + infra integration files)
```

(The exact files evolve over time; consult the template's own README for authoritative details.)

## Post-Generation Next Steps

1. Review the generated `README.md` inside the project
1. Run initial build:

  ```bash
   
  bazel build //projects/template/awesome_fastapi_app/...
  ```
   
1. (If Kubernetes deployment) Prepare local infra via Terraform or Pulumi
1. Start iterative dev (example for FastAPI template):

  ```bash
  skaffold dev -m template-fastapi-app -p dev
  ```

## Template Evolution

Placeholders indicate pipeline support for future templates. Upgrading or adding templates involves updating Copier sources and (if needed) dependency pins under the `scaffolding` group in `third_party/python/pyproject.toml`.

## Troubleshooting

| Issue | Cause | Resolution |
|-------|-------|------------|
| Template not listed | Placeholder not yet promoted | Implement template directory & update registry logic |
| Bazel run fails with dependency errors | Stale Python lock | Regenerate via dependency management workflow |
| Name collision | Directory already exists | Choose new `--project-name` or `--output-dir` |

## Related Docs

- See `docs/dependency-management.md` for Python dependency and drift enforcement details
- Template-specific docs under each template's `docs/` subdirectory
