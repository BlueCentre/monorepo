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
import argparse

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
        """Prompt user for language and project type (interactive mode)."""
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

    def generate_with_copier(self, language: str, project_type: str, project_name: Optional[str] = None, defaults: bool = False) -> Optional[Path]:
        """Generate project using Copier template.

        Args:
            language: Chosen language key.
            project_type: Chosen project type key.
            project_name: Optional explicit project name to pass to Copier.
            defaults: If True, run Copier with defaults (no prompting) when data is sufficient.
        """
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
        try:
            target_base.mkdir(parents=True, exist_ok=True)
            print(f"📁 Target directory prepared: {target_base}")
        except OSError as e:
            print(f"❌ Failed to create target directory {target_base}: {e}")
            return None
        
        try:
            # Prepare data dict for Copier. If project_name supplied, include it to reduce prompts.
            copier_data: Dict[str, str] = {}
            if project_name:
                copier_data["project_name"] = project_name

            if copier_data:
                print(f"🧩 Pre-populating answers: {list(copier_data.keys())}")

            if defaults and not copier_data:
                # Warn that defaults without any provided data may still prompt.
                print("⚠️  Running with --defaults but no pre-populated data; Copier may still prompt.")

            interactive = not defaults
            if interactive:
                print("📋 Copier will now ask you questions to customize your project...\n")
            else:
                print("🤖 Running Copier in non-interactive (defaults) mode")

            result = run_copy(
                src_path=str(template_path),
                dst_path=str(target_base),
                data=copier_data,
                answers_file=None,
                unsafe=True,
                quiet=False,
                defaults=defaults,
            )
            
            # Copier 8 may return a Worker object instead of direct Path.
            project_result_path: Optional[Path] = None
            if isinstance(result, Path):
                project_result_path = result
            else:
                # Try to introspect common attributes on Worker
                candidate = getattr(result, "dst_path", None)
                if isinstance(candidate, (str, Path)):
                    project_result_path = Path(candidate)

            if project_result_path and project_result_path.exists():
                print("\n🎉 Successfully created project!")
                print(f"   📍 Location: {project_result_path}")
                print(f"   🏷️  Template: {config['description']}")
                return project_result_path

            print("❌ Project creation failed")
            print(f"   Unexpected return type from Copier: {type(result)} -> {result}")
            return None
                
        except KeyboardInterrupt:
            print("\n\n❌ Project generation cancelled by user")
            return None
        except (OSError, RuntimeError, ValueError) as e:
            print("\n❌ Error creating project with Copier:", e)
            print("   Template:", template_path)
            print("   Target:", target_base)
            print("   Error type:", type(e).__name__)
            return None

    def show_next_steps(self, project_path: Path, language: str, project_type: str):
        """Show next steps after project creation."""
        print("\n📖 Next steps:")
        print(f"   1. cd {project_path}")
        print("   2. Review and customize the generated files")
        print("   3. Update dependencies as needed")

        # Calculate relative path from workspace root for Bazel targets
        try:
            relative_path = project_path.relative_to(self.workspace_root)
            bazel_target_prefix = f"//{relative_path}"
        except ValueError:
            # Fallback if project is not under workspace root
            bazel_target_prefix = f"//projects/{language}/{project_path.name}"

        if language == "python":
            print(f"   4. Build: bazel build {bazel_target_prefix}/...")
            print(f"   5. Test: bazel test {bazel_target_prefix}/...")
        elif language == "go":
            print(f"   4. Build: bazel build {bazel_target_prefix}/...")
            print(f"   5. Test: bazel test {bazel_target_prefix}/...")
        elif language == "java":
            print(f"   4. Build: bazel build {bazel_target_prefix}/...")
            print(f"   5. Test: bazel test {bazel_target_prefix}/...")

        if project_type in ["fastapi", "gin", "flask"]:
            print("   6. Deploy: skaffold run (if Kubernetes manifests are included)")

    def generate_project(self, args: argparse.Namespace) -> None:
        """Main method to generate a new project.

        Behavior:
            - If --list-templates specified, list and exit.
            - If --language/--project-type provided (and optionally --project-name), run non-interactively.
            - Else fall back to interactive prompt.
        """
        try:
            if getattr(args, "list_templates", False):
                self.print_templates()
                return

            if args.language and args.project_type:
                # Non-interactive mode
                language = args.language
                project_type = args.project_type
                print("🤖 Non-interactive mode: using provided flags --language and --project-type")
                project_path = self.generate_with_copier(
                    language,
                    project_type,
                    project_name=args.project_name,
                    defaults=args.defaults,
                )
                if project_path:
                    self.show_next_steps(project_path, language, project_type)
                else:
                    print("\n🚧 No project was created (non-interactive mode).")
                return

            # Interactive mode
            if not sys.stdin.isatty():
                print("❌ No TTY available and required interactive inputs missing. Provide --language and --project-type (and optionally --project-name).")
                sys.exit(2)

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
        except EOFError:
            print("\n❌ Input stream closed (EOF). Provide flags for non-interactive use: --language --project-type --project-name.")
            sys.exit(2)
        except (OSError, RuntimeError, ValueError) as e:
            print("\n❌ Error generating project:", e)
            sys.exit(1)

    def print_templates(self) -> None:
        """Print available templates (supported + placeholders)."""
        print("📚 Available templates:")
        print("  Supported:")
        for (lang, proj_type), cfg in sorted(self.supported_templates.items()):
            print(f"    - {lang}:{proj_type} -> {cfg['description']}")
        print("  Planned (placeholders):")
        for (lang, proj_type), desc in sorted(self.placeholder_templates.items()):
            print(f"    - {lang}:{proj_type} (planned) -> {desc}")


# Global variable to cache workspace root once determined
_WORKSPACE_ROOT = None


def get_workspace_root() -> Optional[Path]:
    """Get the workspace root, determining it once and caching the result."""
    global _WORKSPACE_ROOT
    if _WORKSPACE_ROOT is None:
        _WORKSPACE_ROOT = find_workspace_root()
    return _WORKSPACE_ROOT


def find_workspace_root() -> Optional[Path]:
    """Find the workspace root directory containing MODULE.bazel using multiple strategies."""
    
    # Strategy 1: Use BUILD_WORKSPACE_DIRECTORY if available (most reliable for bazel run)
    # This is the standard way Bazel communicates the workspace root to scripts
    build_workspace_dir = os.environ.get("BUILD_WORKSPACE_DIRECTORY")
    if build_workspace_dir:
        try:
            workspace_path = Path(build_workspace_dir).resolve()
            if (workspace_path / "MODULE.bazel").exists():
                return workspace_path
            # If MODULE.bazel doesn't exist at BUILD_WORKSPACE_DIRECTORY, something is wrong
            # but let's continue with other strategies
        except (OSError, RuntimeError):
            # Path resolution might fail in some environments
            pass
    
    # Strategy 2: Check current working directory and walk up
    try:
        current = Path.cwd().resolve()
        for parent in [current] + list(current.parents):
            if (parent / "MODULE.bazel").exists():
                return parent
    except (OSError, RuntimeError):
        # Current directory might not be accessible or resolvable
        pass
    
    # Strategy 3: Use script location and walk up (for when not sandboxed)
    try:
        script_path = Path(__file__).resolve()
        for parent in [script_path.parent] + list(script_path.parents):
            if (parent / "MODULE.bazel").exists():
                return parent
    except (NameError, OSError, RuntimeError):
        # __file__ might not be available in some contexts, or path might not be resolvable
        pass
    
    # Strategy 4: Check common Bazel runfiles locations
    runfiles_dir = os.environ.get("RUNFILES_DIR")
    if runfiles_dir:
        try:
            runfiles_path = Path(runfiles_dir).resolve()
            # Look for workspace name in runfiles structure
            for child in runfiles_path.iterdir():
                if child.is_dir() and (child / "MODULE.bazel").exists():
                    return child
            # Also try walking up from runfiles directory
            for parent in [runfiles_path] + list(runfiles_path.parents):
                if (parent / "MODULE.bazel").exists():
                    return parent
        except (OSError, PermissionError, RuntimeError):
            # Runfiles directory might not be accessible
            pass
    
    # Strategy 5: Look for common Git workspace indicators  
    try:
        for parent in [Path.cwd().resolve()] + list(Path.cwd().resolve().parents):
            if (parent / ".git").exists() and (parent / "MODULE.bazel").exists():
                return parent
    except (OSError, RuntimeError):
        # Current directory might not be accessible
        pass
    
    # Strategy 6: Try common paths when running in Bazel sandbox
    # Bazel often creates a sandbox structure, try to find the original workspace
    try:
        # Check if we're in a Bazel sandbox (common patterns)
        current_path = Path.cwd().resolve()
        path_str = str(current_path)
        
        # If we're in execroot, try to find the original workspace
        if "execroot" in path_str:
            # Try to find the workspace by looking for common patterns
            parts = current_path.parts
            for i, part in enumerate(parts):
                if part == "execroot" and i + 1 < len(parts):
                    # The next part is usually the workspace name
                    workspace_name = parts[i + 1]
                    # Try some common locations
                    potential_paths = [
                        Path("/") / "home" / "runner" / "work" / workspace_name / workspace_name,
                        Path("/") / "workspace",
                        Path("/") / "tmp" / workspace_name,
                        current_path.parents[2] if len(current_path.parents) > 2 else None,
                    ]
                    
                    for potential_path in potential_paths:
                        if potential_path and potential_path.exists():
                            module_file = potential_path / "MODULE.bazel"
                            if module_file.exists():
                                return potential_path
                    break
        
        # If current path contains the workspace name, try parent directories
        # This handles cases where we're deep in the sandbox structure
        if "monorepo" in path_str:
            for parent in current_path.parents:
                if parent.name == "monorepo" and (parent / "MODULE.bazel").exists():
                    return parent
                    
    except (OSError, RuntimeError, IndexError):
        # Path operations might fail in restricted environments
        pass
    
    # Strategy 7: Fallback - try hardcoded paths for GitHub Actions/CI environments
    try:
        # Common GitHub Actions paths
        github_workspace = os.environ.get("GITHUB_WORKSPACE")
        if github_workspace:
            workspace_path = Path(github_workspace)
            if (workspace_path / "MODULE.bazel").exists():
                return workspace_path
        
        # Try common CI/workspace paths
        potential_workspace_paths = [
            Path("/home/runner/work/monorepo/monorepo"),
            Path("/workspace"),
            Path("/github/workspace"),
            Path.cwd() / ".." / "workspace" if Path.cwd().name != "workspace" else Path.cwd(),
        ]
        
        for potential_path in potential_workspace_paths:
            if potential_path.exists() and (potential_path / "MODULE.bazel").exists():
                return potential_path.resolve()
                
    except (OSError, RuntimeError):
        pass
    
    return None


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate new monorepo projects using Copier templates",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--language", help="Language key (e.g. python, go, java)")
    parser.add_argument("--project-type", dest="project_type", help="Project type key (e.g. fastapi, cli, gin)")
    parser.add_argument("--project-name", dest="project_name", help="Explicit project name to pass to Copier")
    parser.add_argument("--defaults", action="store_true", help="Run Copier with defaults (non-interactive) where possible")
    parser.add_argument("--list-templates", action="store_true", help="List available templates and exit")
    return parser


def main():
    """Main entry point."""
    arg_parser = build_arg_parser()
    # Bazel passes an extra "--" separator before script args; argparse handles it automatically.
    args = arg_parser.parse_args()

    # Find workspace root using multiple strategies and cache it
    workspace_root = get_workspace_root()
    
    if workspace_root is None:
        print("❌ Error: Could not find MODULE.bazel. Are you in the workspace root?")
        print(f"   Current directory: {Path.cwd()}")
        print(f"   BUILD_WORKSPACE_DIRECTORY: {os.environ.get('BUILD_WORKSPACE_DIRECTORY', 'Not set')}")
        print(f"   RUNFILES_DIR: {os.environ.get('RUNFILES_DIR', 'Not set')}")
        print(f"   GITHUB_WORKSPACE: {os.environ.get('GITHUB_WORKSPACE', 'Not set')}")
        print(f"   PWD: {os.environ.get('PWD', 'Not set')}")
        
        # Show what we actually checked
        print("\n   Checked locations:")
        try:
            current = Path.cwd().resolve()
            for i, parent in enumerate([current] + list(current.parents)[:3]):
                module_file = parent / "MODULE.bazel"
                print(f"   {i+1}. {parent} -> MODULE.bazel exists: {module_file.exists()}")
        except (OSError, RuntimeError) as e:
            print(f"   - Error checking current directory: {e}")
            
        try:
            script_path = Path(__file__).resolve()
            for i, parent in enumerate([script_path.parent] + list(script_path.parents)[:3]):
                module_file = parent / "MODULE.bazel"
                print(f"   {i+4}. {parent} -> MODULE.bazel exists: {module_file.exists()}")
        except (OSError, RuntimeError) as e:
            print(f"   - Error checking script directory: {e}")
        
        print("\n   This error can occur if:")
        print("   1. You're not running from the repository root")
        print("   2. The Bazel environment is not set up correctly")
        print("   3. There are network connectivity issues preventing Bazel from running")
        print("   4. The script is running in a sandboxed environment with limited file access")
        print("\n   Troubleshooting:")
        print("   - Try running: bazel run //tools:new_project")
        print("   - Ensure you're in the workspace root directory")
        print("   - Check if MODULE.bazel exists in the expected location")
        sys.exit(1)
    
    print(f"🏠 Using workspace root: {workspace_root}")
    
    # Check if Copier is available
    try:
        import copier
        print(f"✅ Using Copier {copier.__version__}")
    except ImportError:
        print("❌ Error: Copier is not installed.")
        print("   This tool requires Copier for advanced templating.")
        print("   Please install it with: pip install copier")
        sys.exit(1)
    except AttributeError:
        # Some versions of Copier might not have __version__
        print("✅ Using Copier (version not available)")
    
    generator = CopierProjectGenerator(workspace_root)
    generator.generate_project(args)


if __name__ == "__main__":
    main()