#!/bin/bash
# Simple test script to validate Copier templates are properly configured

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🧪 Testing Copier template configurations..."

# Check that copier.yml files exist
TEMPLATES_DIR="$WORKSPACE_ROOT/projects/template"

for template_dir in "$TEMPLATES_DIR"/*; do
    if [[ -d "$template_dir" ]]; then
        template_name=$(basename "$template_dir")
        copier_file="$template_dir/copier.yml"
        
        if [[ -f "$copier_file" ]]; then
            echo "✅ $template_name: copier.yml found"
            
            # Basic YAML syntax validation
            if command -v python3 >/dev/null 2>&1; then
                python3 -c "
import yaml
try:
    with open('$copier_file', 'r') as f:
        yaml.safe_load(f)
    print('  📝 Valid YAML syntax')
except Exception as e:
    print(f'  ❌ YAML syntax error: {e}')
    exit(1)
" || exit 1
            fi
            
            # Check for README.md.jinja template
            readme_template="$template_dir/README.md.jinja"
            if [[ -f "$readme_template" ]]; then
                echo "  📋 README.md.jinja template found"
            else
                echo "  ⚠️  README.md.jinja template missing"
            fi
        else
            echo "⚠️  $template_name: copier.yml missing"
        fi
    fi
done

echo ""
echo "🎯 Template validation complete!"
echo "💡 To test template generation:"
echo "   bazel run //tools:new_project"