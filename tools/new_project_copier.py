#!/usr/bin/env python3
"""
New Project Generator for MonoRepo using Copier

Creates new projects based on templates with interactive prompts using Copier.
Usage: bazel run //tools:new_project
"""

import os
import sys
from pathlib import Path
from typing import Dict, List, Optional
import subprocess

try:
    from copier import run_copy
except ImportError:
    print("❌ Error: Copier is not available. Please ensure it's installed.")
    print("   Run: pip install copier")
    sys.exit(1)


class CopierProjectGenerator:
    """Generates new projects using Copier templates."""
    
    def __init__(self, workspace_root: Path):
        self.workspace_root = workspace_root
        self.templates_dir = workspace_root / "projects" / "template"
        self.projects_dir = workspace_root / "projects"
        
        # Define supported templates with their Copier configurations
        self.supported_templates = {
            ("python", "fastapi"): {
                "template_dir": "template_fastapi_app",
                "target_subdir": "python",
                "description": "Production-ready FastAPI web service"
            },
            ("python", "cli"): {
                "template_dir": "template_typer_app", 
                "target_subdir": "python",
                "description": "Command-line interface using Typer"
            },
            ("go", "gin"): {
                "template_dir": "template_gin_app",
                "target_subdir": "go", 
                "description": "Web service using Go Gin framework"
            },
        }
        
        # Define placeholders for future templates
        self.placeholder_templates = {
            ("java", "springboot"): "Spring Boot web service template",
            ("python", "flask"): "Flask web application template", 
            ("go", "cli"): "Go command-line application template",
        }

    def get_language_choices(self) -> List[str]:
        """Get available language choices."""
        languages = set()
        for lang, _ in self.supported_templates.keys():
            languages.add(lang)
        for lang, _ in self.placeholder_templates.keys():
            languages.add(lang)
        return sorted(languages)

    def get_project_type_choices(self, language: str) -> List[tuple]:
        """Get available project type choices for a language with status."""
        choices = []
        
        # Add supported templates
        for (lang, proj_type), config in self.supported_templates.items():
            if lang == language:
                choices.append((proj_type, "✅", config["description"]))
        
        # Add placeholder templates  
        for (lang, proj_type), desc in self.placeholder_templates.items():
            if lang == language:
                choices.append((proj_type, "🚧", desc))
                
        return sorted(choices)

    def prompt_user_input(self) -> tuple[str, str]:
        """Prompt user for language and project type."""
        print("🚀 Welcome to the MonoRepo Project Generator!")
        print("   Powered by Copier for advanced templating")
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
        project_choices = self.get_project_type_choices(language)
        print(f"\nAvailable project types for {language}:")
        for i, (proj_type, status, desc) in enumerate(project_choices, 1):
            print(f"  {i}. {proj_type} {status} - {desc}")
        
        while True:
            try:
                choice = input(f"\nSelect project type (1-{len(project_choices)}): ").strip()
                type_idx = int(choice) - 1
                if 0 <= type_idx < len(project_choices):
                    project_type, status, desc = project_choices[type_idx]
                    break
                else:
                    print(f"❌ Please enter a number between 1 and {len(project_choices)}")
            except ValueError:
                print("❌ Please enter a valid number")
        
        print(f"✅ Selected project type: {project_type}")
        
        return language, project_type

    def generate_with_copier(self, language: str, project_type: str) -> Optional[Path]:
        """Generate project using Copier template."""
        template_key = (language, project_type)
        
        if template_key not in self.supported_templates:
            print(f"❌ Template not yet available for {language} {project_type}")
            print("🚧 This combination is planned but not implemented yet.")
            return None
            
        config = self.supported_templates[template_key]
        template_path = self.templates_dir / config["template_dir"]
        
        # Verify template exists and has copier.yml
        copier_config = template_path / "copier.yml"
        if not copier_config.exists():
            print(f"❌ Template configuration missing: {copier_config}")
            print("   Template may not be properly configured for Copier.")
            return None
        
        print(f"\n🔨 Creating {language} {project_type} project using Copier...")
        print(f"📂 Template: {template_path}")
        
        # Determine target directory
        target_base = self.projects_dir / config["target_subdir"]
        target_base.mkdir(parents=True, exist_ok=True)
        
        try:
            # Run Copier interactively
            print(f"📋 Copier will now ask you questions to customize your project...\n")
            
            # Use Copier to generate the project
            # Note: Copier will prompt for project_name and create the directory
            result = run_copy(
                src_path=str(template_path),
                dst_path=str(target_base),
                data={},  # Let Copier prompt for all data
                answers_file=None,
                unsafe=True,  # Allow templates to run arbitrary code (needed for our setup)
                quiet=False,
                defaults=False,  # Force prompting for all questions
            )
            
            if result:
                project_path = Path(result)
                print(f"\n🎉 Successfully created project!")
                print(f"   📍 Location: {project_path}")
                print(f"   🏷️  Template: {config['description']}")
                return project_path
            else:
                print("❌ Project creation failed")
                return None
                
        except KeyboardInterrupt:
            print("\n\n❌ Project generation cancelled by user")
            return None
        except Exception as e:
            print(f"\n❌ Error creating project with Copier: {e}")
            print(f"   Template: {template_path}")
            return None

    def show_next_steps(self, project_path: Path, language: str, project_type: str):
        """Show next steps after project creation."""
        print(f"\n📖 Next steps:")
        print(f"   1. cd {project_path}")
        print(f"   2. Review and customize the generated files")
        print(f"   3. Update dependencies as needed")
        
        if language == "python":
            print(f"   4. Build: bazel build //projects/{language}/{project_path.name}/...")
            print(f"   5. Test: bazel test //projects/{language}/{project_path.name}/...")
        elif language == "go":
            print(f"   4. Build: bazel build //projects/{language}/{project_path.name}/...")
            print(f"   5. Test: bazel test //projects/{language}/{project_path.name}/...")
        elif language == "java":
            print(f"   4. Build: bazel build //projects/{language}/{project_path.name}/...")
            print(f"   5. Test: bazel test //projects/{language}/{project_path.name}/...")
        
        if project_type in ["fastapi", "gin", "flask"]:
            print(f"   6. Deploy: skaffold run (if Kubernetes manifests are included)")

    def generate_project(self) -> None:
        """Main method to generate a new project."""
        try:
            language, project_type = self.prompt_user_input()
            
            project_path = self.generate_with_copier(language, project_type)
            
            if project_path:
                self.show_next_steps(project_path, language, project_type)
            else:
                print("\n🚧 No project was created.")
                print("   Consider contributing a template for this combination!")
                
        except KeyboardInterrupt:
            print("\n\n❌ Project generation cancelled by user")
            sys.exit(1)
        except Exception as e:
            print(f"\n❌ Error generating project: {e}")
            sys.exit(1)


def main():
    """Main entry point."""
    # Determine workspace root - use current working directory since bazel runs from workspace root
    workspace_root = Path.cwd()
    
    # If MODULE.bazel not found in cwd, try to find it by walking up the directory tree
    if not (workspace_root / "MODULE.bazel").exists():
        current = workspace_root
        found = False
        # Walk up the directory tree looking for MODULE.bazel
        for parent in [current] + list(current.parents):
            if (parent / "MODULE.bazel").exists():
                workspace_root = parent
                found = True
                break
        
        if not found:
            print("❌ Error: Could not find MODULE.bazel. Are you in the workspace root?")
            print(f"   Searched from: {Path.cwd()}")
            sys.exit(1)
    
    # Check if Copier is available
    try:
        import copier
        print(f"✅ Using Copier {copier.__version__}")
    except ImportError:
        print("❌ Error: Copier is not installed.")
        print("   This tool requires Copier for advanced templating.")
        print("   Please install it with: pip install copier")
        sys.exit(1)
    
    generator = CopierProjectGenerator(workspace_root)
    generator.generate_project()


if __name__ == "__main__":
    main()