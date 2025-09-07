#!/usr/bin/env python3
"""
New Project Generator for MonoRepo

Creates new projects based on templates with interactive prompts.
Usage: bazel run //tools:new_project
"""

import shutil
import sys
from pathlib import Path


class ProjectGenerator:
    """Generates new projects from templates."""

    def __init__(self, workspace_root: Path):
        self.workspace_root = workspace_root
        self.templates_dir = workspace_root / "projects" / "template"
        self.projects_dir = workspace_root / "projects"

        # Define supported combinations with their template paths
        self.supported_templates = {
            ("python", "fastapi"): "template_fastapi_app",
            ("python", "cli"): "template_typer_app",
            ("go", "gin"): "template_gin_app",
        }

        # Define placeholders for future templates
        self.placeholder_templates = {
            ("java", "springboot"): "Coming soon - Spring Boot template",
            ("python", "flask"): "Coming soon - Flask template",
            ("go", "cli"): "Coming soon - Go CLI template",
        }

    def get_language_choices(self) -> list[str]:
        """Get available language choices."""
        languages = set()
        for lang, _ in self.supported_templates.keys():
            languages.add(lang)
        for lang, _ in self.placeholder_templates.keys():
            languages.add(lang)
        return sorted(languages)

    def get_project_type_choices(self, language: str) -> list[str]:
        """Get available project type choices for a language."""
        types = set()
        for lang, proj_type in self.supported_templates.keys():
            if lang == language:
                types.add(proj_type)
        for lang, proj_type in self.placeholder_templates.keys():
            if lang == language:
                types.add(proj_type)
        return sorted(types)

    def prompt_user_input(self) -> tuple[str, str, str]:
        """Prompt user for language, project type, and name."""
        print("🚀 Welcome to the MonoRepo Project Generator!")
        print()

        # Get language
        languages = self.get_language_choices()
        print("Available languages:")
        for i, lang in enumerate(languages, 1):
            print(f"  {i}. {lang}")

        while True:
            try:
                choice = input(f"\nSelect language (1-{len(languages)}): ").strip()
                lang_idx = int(choice) - 1
                if 0 <= lang_idx < len(languages):
                    language = languages[lang_idx]
                    break
                else:
                    print(f"❌ Please enter a number between 1 and {len(languages)}")
            except ValueError:
                print("❌ Please enter a valid number")

        print(f"✅ Selected language: {language}")

        # Get project type
        project_types = self.get_project_type_choices(language)
        print(f"\nAvailable project types for {language}:")
        for i, proj_type in enumerate(project_types, 1):
            status = "✅" if (language, proj_type) in self.supported_templates else "🚧"
            print(f"  {i}. {proj_type} {status}")

        while True:
            try:
                choice = input(f"\nSelect project type (1-{len(project_types)}): ").strip()
                type_idx = int(choice) - 1
                if 0 <= type_idx < len(project_types):
                    project_type = project_types[type_idx]
                    break
                else:
                    print(f"❌ Please enter a number between 1 and {len(project_types)}")
            except ValueError:
                print("❌ Please enter a valid number")

        print(f"✅ Selected project type: {project_type}")

        # Get project name
        while True:
            project_name = input("\nEnter project name (e.g., my_awesome_app): ").strip()
            if project_name and project_name.replace("_", "").replace("-", "").isalnum():
                # Validate project doesn't already exist
                target_dir = self.projects_dir / language / project_name
                if target_dir.exists():
                    print(f"❌ Project {target_dir} already exists. Please choose a different name.")
                    continue
                break
            else:
                print("❌ Project name must contain only alphanumeric characters, hyphens, and underscores")

        print(f"✅ Selected project name: {project_name}")

        return language, project_type, project_name

    def copy_template(self, template_name: str, language: str, project_name: str) -> Path:
        """Copy template to new project location."""
        source_dir = self.templates_dir / template_name
        target_dir = self.projects_dir / language / project_name

        if not source_dir.exists():
            raise FileNotFoundError(f"Template directory {source_dir} not found")

        print(f"📁 Creating project directory: {target_dir}")
        target_dir.parent.mkdir(parents=True, exist_ok=True)

        print(f"📋 Copying template from {source_dir}")
        shutil.copytree(source_dir, target_dir)

        return target_dir

    def customize_project(self, project_dir: Path, project_name: str, language: str, project_type: str):
        """Customize the copied project with project-specific information."""
        print(f"🔧 Customizing project in {project_dir}")

        # Update README.md with project name
        readme_path = project_dir / "README.md"
        if readme_path.exists():
            try:
                with open(readme_path, encoding="utf-8") as f:
                    content = f.read()

                # Replace the first line with project name if it starts with "# Template"
                lines = content.split("\n")
                if lines and lines[0].startswith("# Template"):
                    lines[0] = f"# {project_name.replace('_', ' ').title()}"

                    # Add a note about being generated
                    lines.insert(
                        2, f"*Generated from {language} {project_type} template using `bazel run //tools:new_project`*"
                    )
                    lines.insert(3, "")

                    with open(readme_path, "w", encoding="utf-8") as f:
                        f.write("\n".join(lines))
                    print("  📝 Updated: README.md")

            except Exception as e:
                print(f"⚠️  Warning: Could not customize README.md: {e}")

        # Create a .project-info file for reference
        project_info = f"""# Project Information
name: {project_name}
language: {language}
project_type: {project_type}
template_source: {self.supported_templates.get((language, project_type), 'custom')}
generated_by: bazel run //tools:new_project
"""
        try:
            with open(project_dir / ".project-info", "w") as f:
                f.write(project_info)
            print("  📝 Created: .project-info")
        except Exception as e:
            print(f"⚠️  Warning: Could not create .project-info: {e}")

    def create_placeholder_project(self, language: str, project_type: str, project_name: str) -> Path:
        """Create a minimal placeholder project for unsupported combinations."""
        target_dir = self.projects_dir / language / project_name
        target_dir.mkdir(parents=True, exist_ok=True)

        # Create basic BUILD.bazel file
        build_content = f"""# {project_name} - {language} {project_type} application
# TODO: This is a placeholder project. Template not yet available.

# Placeholder target
genrule(
    name = "placeholder",
    outs = ["README_PLACEHOLDER.md"],
    cmd = "echo 'This is a placeholder for {language} {project_type} project: {project_name}' > $@",
    visibility = ["//visibility:public"],
)
"""

        with open(target_dir / "BUILD.bazel", "w") as f:
            f.write(build_content)

        # Create README
        readme_content = f"""# {project_name}

This is a placeholder project for a {language} {project_type} application.

## Status
🚧 **Template not yet available** - This project was created as a placeholder.

## Next Steps
1. Implement the actual {project_type} application
2. Update BUILD.bazel with proper build rules for {language}
3. Add proper documentation and dependencies
4. Consider contributing a template for {language} {project_type} projects

## Template Information
- **Language**: {language}
- **Project Type**: {project_type}
- **Generated**: This project was generated using `bazel run //tools:new_project`
"""

        with open(target_dir / "README.md", "w") as f:
            f.write(readme_content)

        return target_dir

    def generate_project(self) -> None:
        """Main method to generate a new project."""
        try:
            language, project_type, project_name = self.prompt_user_input()

            print(f"\n🔨 Creating {language} {project_type} project: {project_name}")

            template_key = (language, project_type)

            if template_key in self.supported_templates:
                # Use existing template
                template_name = self.supported_templates[template_key]
                project_dir = self.copy_template(template_name, language, project_name)
                self.customize_project(project_dir, project_name, language, project_type)
                status = "✅ Template"
            elif template_key in self.placeholder_templates:
                # Create placeholder project
                project_dir = self.create_placeholder_project(language, project_type, project_name)
                status = "🚧 Placeholder"
            else:
                print(f"❌ Unsupported combination: {language} {project_type}")
                return

            print("\n🎉 Successfully created project!")
            print(f"   📍 Location: {project_dir}")
            print(f"   🏷️  Status: {status}")
            print("\n📖 Next steps:")
            print(f"   1. cd {project_dir}")
            if template_key in self.supported_templates:
                print("   2. Review and customize the generated files")
                print("   3. Update dependencies as needed")
                print("   4. Build and test: bazel test //...")
            else:
                print(f"   2. Implement your {project_type} application")
                print("   3. Add proper BUILD.bazel rules")

        except KeyboardInterrupt:
            print("\n\n❌ Project generation cancelled by user")
            sys.exit(1)
        except Exception as e:
            print(f"\n❌ Error creating project: {e}")
            sys.exit(1)


def main():
    """Main entry point."""
    # Determine workspace root
    script_dir = Path(__file__).parent
    workspace_root = script_dir.parent

    # Verify we're in a valid workspace
    if not (workspace_root / "MODULE.bazel").exists():
        print("❌ Error: Could not find MODULE.bazel. Are you in the workspace root?")
        sys.exit(1)

    generator = ProjectGenerator(workspace_root)
    generator.generate_project()


if __name__ == "__main__":
    main()
