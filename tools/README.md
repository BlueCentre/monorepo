# Development Tools

This directory contains tools for development and build automation.

## Available Tools

### new_project
Interactive and non-interactive project generator that creates new projects from templates using **Copier** for advanced templating. Projects are always created inside a dedicated subdirectory: `projects/<language>/<project_name>/` (or under a custom `--output-dir`).

```bash
# Interactive (prompts)
bazel run //tools:new_project

# Non-interactive (fully automated). The --project-name flag is strongly recommended; if omitted a default like
# '<project-type>-app' is derived to avoid writing directly into the language root.
bazel run //tools:new_project -- \
  --language python \
  --project-type cli \
  --project-name awesome_cli_tool

# Dry run (pretend) - preview without writing files
bazel run //tools:new_project -- \
  --language python --project-type cli \
  --project-name test_cli --dry-run

# Custom output directory (relative to workspace root or absolute)
bazel run //tools:new_project -- \
  --language go --project-type gin \
  --project-name acme_api \
  --output-dir custom/projects/go

# List templates
bazel run //tools:new_project -- --list-templates
```

**Features:**
- **Powered by Copier**: Uses industry-standard Copier templating for sophisticated project generation
- **Interactive Questionnaires**: Rich prompting system with validation and defaults
- **Jinja2 Templating**: Full Jinja2 support in templates for dynamic content generation
- **Template Versioning**: Support for template updates and migrations (future)
- **Extensible**: Easy to add new templates and customize existing ones
- **Non-interactive Mode**: Script-friendly via `--language`, `--project-type`, `--project-name` (a safe default name will be derived if omitted)
- **Dry Run Support**: Use `--dry-run` to run Copier in pretend mode (no files written)
- **Custom Output Directory**: Override default language-based path with `--output-dir`
- **Template Discovery**: Use `--list-templates` to view available & planned templates
- **Name Sanitization**: Invalid names are automatically normalized (e.g. `My Project!` -> `my-project`)

**Process (Interactive):**
1. Prompts for language (Python, Go, Java)
2. Prompts for project type (FastAPI, CLI, Gin, Spring Boot, etc.)  
3. Copier questionnaire asks for project-specific details (name, description, author, etc.)
4. Template files are processed with Jinja2 and customized
5. Complete project structure is generated with proper README and documentation

**Non-Interactive Flow:**
When `--language` and `--project-type` are supplied, prompts are skipped. Optional flags:

| Flag | Purpose |
|------|---------|
| `--project-name` | Pre-populate project name answer (sanitized) |
| `--defaults` | Accept template default answers automatically |
| `--dry-run` | Pretend mode: show actions, write nothing |
| `--output-dir` | Override target directory (absolute or relative) |
| `--list-templates` | List templates and exit |

**Project Directory & Name Rules:**
* A project-specific subdirectory is always created (never writes directly into `projects/<language>`)
* Lowercased
* Spaces replaced with `-`
* Invalid characters removed (only `[a-z0-9_-]` kept)
* Ensures leading letter (prefixes `p` if necessary)
* Collapses duplicate separators
* Fallback value `project`

**Template System:**

- Templates are located in `projects/template/`  
- Each template has a `copier.yml` configuration file
- Template files use `.jinja` extension for Jinja2 processing
- Supports complex template logic, conditionals, and computed values

### Python Dependency Management (uv)

The repository uses `uv` to manage Python dependencies centrally:

- Source of truth: `third_party/python/pyproject.toml`
- Lock file: `third_party/python/uv.lock`
- Bazel-consumed export: `third_party/python/requirements_lock_3_11.txt` (single-lock model; includes base + optional groups `tooling`, `test`, `scaffolding`)
- Python interpreter version for resolution: `.python-version` (baseline `3.11`)

Update workflow:

```bash
# Edit pyproject.toml (add or bump dependency)
$EDITOR third_party/python/pyproject.toml

# (Optional) Adjust Python baseline
echo 3.11 > third_party/python/.python-version   # if changing interpreter version

# Regenerate uv.lock + exported lock
bazel run //third_party/python:requirements_3_11.update

# Commit changes
git add third_party/python/pyproject.toml third_party/python/uv.lock third_party/python/requirements_lock_3_11.txt third_party/python/.python-version
git commit -m "chore(python): update deps"
```

See `third_party/python/COPIER_UPDATE.md` for Copier-specific upgrade details (authoritative doc after uv migration).

For an ad-hoc local virtual environment (e.g. editor integration) run:

```bash
./scripts/setup_uv_env.sh --groups tooling,test,scaffolding
source .uv-venv/bin/activate
```

This mirrors (group-inclusive) dependencies used by Bazel without needing `pip install` steps inside individual project folders.

### new_project_legacy

The original custom implementation (available for comparison).

```bash
bazel run //tools:new_project_legacy
```

See the main [README](../README.md#quick-project-creation) for supported languages and project types.

## Template Development

To create a new Copier template:

1. Create a directory in `projects/template/template_<type>_app/`
2. Add a `copier.yml` configuration file with questions
3. Create template files with `.jinja` extensions
4. Update the `supported_templates` in `new_project_copier.py`

Example `copier.yml`:

```yaml
project_name:
  type: str
  help: Enter the project name
  validator: "{% if not project_name.isalnum() %}Invalid name{% endif %}"

project_description:
  type: str
  help: Enter project description
  default: "A new project"
```

## Other Tools

- `pytest/` - Python testing configurations
- `scripts/` - Various build and development scripts
