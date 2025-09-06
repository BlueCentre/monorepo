# Development Tools

This directory contains tools for development and build automation.

## Available Tools

### new_project
Interactive project generator that creates new projects from templates using **Copier** for advanced templating.

```bash
bazel run //tools:new_project
```

**Features:**
- **Powered by Copier**: Uses industry-standard Copier templating for sophisticated project generation
- **Interactive Questionnaires**: Rich prompting system with validation and defaults
- **Jinja2 Templating**: Full Jinja2 support in templates for dynamic content generation
- **Template Versioning**: Support for template updates and migrations (future)
- **Extensible**: Easy to add new templates and customize existing ones

**Process:**
1. Prompts for language (Python, Go, Java)
2. Prompts for project type (FastAPI, CLI, Gin, Spring Boot, etc.)  
3. Copier questionnaire asks for project-specific details (name, description, author, etc.)
4. Template files are processed with Jinja2 and customized
5. Complete project structure is generated with proper README and documentation

**Template System:**
- Templates are located in `projects/template/`  
- Each template has a `copier.yml` configuration file
- Template files use `.jinja` extension for Jinja2 processing
- Supports complex template logic, conditionals, and computed values

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
