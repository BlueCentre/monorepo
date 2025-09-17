#!/bin/bash
# Validation script for Cloud Run Skaffold configuration
set -euo pipefail

echo "🔍 Validating Cloud Run Skaffold Configuration"
echo "=============================================="

# Check if required environment variables are set or provide examples
echo "📋 Environment Variables Check:"

required_vars=("GCP_PROJECT_ID" "GCP_REGION" "ARTIFACT_REGISTRY_LOCATION" "ARTIFACT_REGISTRY_REPO" "GITHUB_SHA")
missing_vars=()

for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        missing_vars+=("$var")
        echo "❌ $var: Not set"
    else
        # Mask sensitive parts of the value for security
        value="${!var}"
        if [[ ${#value} -gt 20 ]]; then
            masked_value="${value:0:10}...${value: -5}"
        else
            masked_value="$value"
        fi
        echo "✅ $var: $masked_value"
    fi
done

if [[ ${#missing_vars[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️  Missing required environment variables. Example configuration:"
    echo ""
    echo "export GCP_PROJECT_ID=\"my-project-id\""
    echo "export GCP_REGION=\"us-central1\""
    echo "export ARTIFACT_REGISTRY_LOCATION=\"us-central1-docker.pkg.dev\""
    echo "export ARTIFACT_REGISTRY_REPO=\"my-project-id/my-repo\""
    echo "export GITHUB_SHA=\"\$(git rev-parse --short HEAD)\""
    echo ""
    echo "Or create a .env file and source it:"
    echo "source skaffold.env.local"
    echo ""
fi

echo ""
echo "🔧 Application Configuration Check:"

# List applications with Cloud Run support
apps=(
    "template-fastapi-app:projects/template/template_fastapi_app"
    "template-gin-app:projects/template/template_gin_app" 
    "echo-fastapi-app:projects/py/echo_fastapi_app"
    "awesome-fastapi-app:projects/py/awesome_fastapi_app"
    "devops-fastapi-app-config:projects/py/devops_fastapi_app"
)

for app_info in "${apps[@]}"; do
    IFS=':' read -r app_name app_path <<< "$app_info"
    
    config_found=false
    config_type=""
    
    if [[ -f "$app_path/skaffold.yaml" ]]; then
        config_type="YAML"
        if grep -q "name: cloudrun" "$app_path/skaffold.yaml"; then
            config_found=true
        fi
    fi
    
    if [[ -f "$app_path/skaffold.yaml.jinja" ]]; then
        config_type="Jinja template"
        if grep -q "name: cloudrun" "$app_path/skaffold.yaml.jinja"; then
            config_found=true
        fi
    fi
    
    if [[ "$config_found" == true ]]; then
        echo "✅ $app_name: Cloud Run profile found ($config_type)"
    elif [[ -n "$config_type" ]]; then
        echo "❌ $app_name: Cloud Run profile missing ($config_type)"
    else
        echo "⚠️  $app_name: No skaffold configuration file found"
    fi
done

echo ""
echo "📚 Usage Examples:"
echo ""
echo "# Deploy Template FastAPI App to Cloud Run"
echo "skaffold deploy -m template-fastapi-app -p cloudrun"
echo ""
echo "# Deploy Echo FastAPI App to Cloud Run"  
echo "skaffold deploy -m echo-fastapi-app -p cloudrun"
echo ""
echo "# Build and deploy in one command"
echo "skaffold run -m template-fastapi-app -p cloudrun"
echo ""

if [[ ${#missing_vars[@]} -eq 0 ]]; then
    echo "🎉 All configuration checks passed!"
    echo ""
    echo "Next steps:"
    echo "1. Authenticate with Google Cloud: gcloud auth login"
    echo "2. Set your project: gcloud config set project \$GCP_PROJECT_ID"
    echo "3. Enable APIs: gcloud services enable run.googleapis.com artifactregistry.googleapis.com"
    echo "4. Deploy your application using one of the commands above"
else
    echo "⚠️  Please set the missing environment variables before deploying to Cloud Run"
fi

echo ""
echo "For detailed instructions, see: docs/cloud-run-deployment.md"