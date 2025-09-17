# Google Cloud Run Deployment with Skaffold

This guide explains how to deploy containerized applications from the monorepo to Google Cloud Run using Skaffold profiles.

## Overview

Cloud Run is a fully managed serverless platform that automatically scales your containers. The monorepo provides consistent `cloudrun` Skaffold profiles for all containerized application types, allowing you to deploy them as serverless applications with minimal configuration.

## Supported Applications

The following applications support Cloud Run deployment:

| Application | Module Name | Language | Framework |
|-------------|-------------|-----------|-----------|
| Template FastAPI App | `template-fastapi-app` | Python | FastAPI |
| Template Gin App | `template-gin-app` | Go | Gin |
| Echo FastAPI App | `echo-fastapi-app` | Python | FastAPI |
| Awesome FastAPI App | `awesome-fastapi-app` | Python | FastAPI |
| DevOps FastAPI App | `devops-fastapi-app-config` | Python | FastAPI |

## Prerequisites

### 1. Google Cloud Setup

```bash
# Install Google Cloud CLI (if not already installed)
# Follow: https://cloud.google.com/sdk/docs/install

# Authenticate with Google Cloud
gcloud auth login

# Set your project ID
export GCP_PROJECT_ID="your-project-id"
gcloud config set project $GCP_PROJECT_ID

# Enable required APIs
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### 2. Artifact Registry Setup

```bash
# Set your preferred region
export GCP_REGION="us-central1"

# Create an Artifact Registry repository
export ARTIFACT_REGISTRY_REPO="monorepo-apps"
gcloud artifacts repositories create $ARTIFACT_REGISTRY_REPO \
  --repository-format=docker \
  --location=$GCP_REGION \
  --description="Container images for monorepo applications"
```

### 3. Environment Configuration

Update the `skaffold.env` file in the monorepo root:

```bash
# Copy the template and edit
cp skaffold.env skaffold.env.local

# Edit skaffold.env.local with your values:
# GCP_PROJECT_ID=your-project-id
# GCP_REGION=us-central1
# ARTIFACT_REGISTRY_LOCATION=us-central1-docker.pkg.dev
# ARTIFACT_REGISTRY_REPO=your-project-id/monorepo-apps
# GITHUB_SHA=latest
```

Or export environment variables directly:

```bash
export GCP_PROJECT_ID="your-project-id"
export GCP_REGION="us-central1"
export ARTIFACT_REGISTRY_LOCATION="us-central1-docker.pkg.dev"
export ARTIFACT_REGISTRY_REPO="$GCP_PROJECT_ID/monorepo-apps"
export GITHUB_SHA="$(git rev-parse --short HEAD)"
```

## Deployment Commands

### Deploy a Single Application

```bash
# Deploy Template FastAPI App to Cloud Run
skaffold deploy -m template-fastapi-app -p cloudrun

# Deploy Template Gin App to Cloud Run
skaffold deploy -m template-gin-app -p cloudrun

# Deploy Echo FastAPI App to Cloud Run
skaffold deploy -m echo-fastapi-app -p cloudrun

# Deploy Awesome FastAPI App to Cloud Run
skaffold deploy -m awesome-fastapi-app -p cloudrun

# Deploy DevOps FastAPI App to Cloud Run
skaffold deploy -m devops-fastapi-app-config -p cloudrun
```

### Build and Deploy Pipeline

For a complete build and deploy workflow:

```bash
# Build the container image and push to Artifact Registry
skaffold build -m template-fastapi-app -p cloudrun

# Then deploy to Cloud Run
skaffold deploy -m template-fastapi-app -p cloudrun
```

### Deploy Multiple Applications

```bash
# Deploy all supported applications (be careful with this!)
for app in template-fastapi-app template-gin-app echo-fastapi-app awesome-fastapi-app; do
  echo "Deploying $app to Cloud Run..."
  skaffold deploy -m $app -p cloudrun
done
```

## Configuration Details

### Skaffold Cloud Run Profile

The `cloudrun` profile makes the following changes to the default configuration:

1. **Deployer**: Switches from `kubectl` to `cloudrun` deployer
2. **Image Push**: Enables image pushing to Artifact Registry
3. **Tag Policy**: Uses environment template for consistent image tagging
4. **Project and Region**: Uses environment variables for GCP configuration

Example profile configuration:
```yaml
- name: cloudrun
  patches:
    - op: replace
      path: /deploy
      value:
        cloudrun:
          projectid: "{{.GCP_PROJECT_ID}}"
          region: "{{.GCP_REGION}}"
    - op: add
      path: /build/local/push
      value: true
    - op: add
      path: /build/tagPolicy
      value:
        envTemplate:
          template: "{{.ARTIFACT_REGISTRY_LOCATION}}/{{.GCP_PROJECT_ID}}/{{.ARTIFACT_REGISTRY_REPO}}/app-name:{{.GITHUB_SHA}}"
```

## Accessing Deployed Applications

After deployment, Cloud Run provides a unique URL for each service:

```bash
# Get the service URL
gcloud run services describe template-fastapi-app \
  --region=$GCP_REGION \
  --format='value(status.url)'

# Test the deployment
curl "$(gcloud run services describe template-fastapi-app --region=$GCP_REGION --format='value(status.url)')/health"
```

## Cleanup

To delete deployed Cloud Run services:

```bash
# Delete a specific service
gcloud run services delete template-fastapi-app --region=$GCP_REGION --quiet

# Delete all services from this project (be careful!)
gcloud run services list --format='value(metadata.name)' | \
  xargs -I {} gcloud run services delete {} --region=$GCP_REGION --quiet
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```bash
   # Re-authenticate and configure Docker
   gcloud auth login
   gcloud auth configure-docker $ARTIFACT_REGISTRY_LOCATION
   ```

2. **Registry Permissions**
   ```bash
   # Ensure you have the required IAM roles
   gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
     --member="user:your-email@domain.com" \
     --role="roles/artifactregistry.writer"
   ```

3. **Environment Variables Not Set**
   ```bash
   # Verify environment variables are set
   echo $GCP_PROJECT_ID
   echo $GCP_REGION
   echo $ARTIFACT_REGISTRY_LOCATION
   echo $ARTIFACT_REGISTRY_REPO
   ```

### Debugging Deployment Issues

```bash
# Check Skaffold configuration
skaffold config list

# Dry run to see what would be deployed
skaffold deploy -m template-fastapi-app -p cloudrun --dry-run

# Enable verbose logging
skaffold deploy -m template-fastapi-app -p cloudrun -v info
```

## Best Practices

1. **Environment Separation**: Use different GCP projects for dev, staging, and production
2. **Image Tagging**: Use meaningful tags (git SHA, semantic versions) for production deployments
3. **Resource Limits**: Configure appropriate CPU and memory limits in Cloud Run
4. **Security**: Use least-privilege IAM roles and enable authentication for production services
5. **Monitoring**: Enable Cloud Run logging and monitoring for production deployments

## Integration with CI/CD

This Cloud Run deployment approach integrates well with CI/CD pipelines:

```yaml
# Example GitHub Actions workflow snippet
- name: Deploy to Cloud Run
  run: |
    export GCP_PROJECT_ID="${{ secrets.GCP_PROJECT_ID }}"
    export GCP_REGION="${{ secrets.GCP_REGION }}"
    export ARTIFACT_REGISTRY_LOCATION="${{ secrets.ARTIFACT_REGISTRY_LOCATION }}"
    export ARTIFACT_REGISTRY_REPO="${{ secrets.ARTIFACT_REGISTRY_REPO }}"
    export GITHUB_SHA="${{ github.sha }}"
    
    skaffold deploy -m template-fastapi-app -p cloudrun
```

For more information, see the [Skaffold Cloud Run documentation](https://skaffold.dev/docs/deployers/cloudrun/).