# Terraform Local Development Environment

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Colima](https://img.shields.io/badge/colima-local_k8s-blue?style=for-the-badge)](https://github.com/abiosoft/colima)

A Terraform-based toolkit for provisioning and managing essential Kubernetes components for local containerized application development.

## Overview

This directory contains a comprehensive set of Terraform configurations designed to provision and manage essential Kubernetes components for containerized application development in a local environment (specifically using Colima). This setup provides a consistent, reproducible way to deploy commonly used infrastructure components that support modern application development workflows.

## Key Components Available

The configuration allows developers to selectively enable and deploy:

| Component | Description | Status |
|-----------|-------------|--------|
| **Cert Manager** | Automates the management and issuance of TLS certificates | ✅ Active |
| **Istio** | Service mesh for traffic management, security, and observability | ✅ Active |
| **OpenTelemetry** | Application monitoring and distributed tracing | ✅ Active | 
| **Argo CD** | GitOps continuous delivery tool | ✅ Active |
| **Telepresence** | Local development tool for remote Kubernetes connections | ✅ Active |
| **External Secrets** | Integration with external secret management systems | ✅ Active |
| **External DNS** | Automated DNS configuration | ✅ Active |
| **Datadog** | Application monitoring and analytics | 🔄 Inactive |
| **CloudNativePG** | Kubernetes operator for PostgreSQL database clusters | ✅ Active |

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0+)
- [Colima](https://github.com/abiosoft/colima) or another local Kubernetes environment
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) configured to work with your local cluster

### Quick Start

1. **Initialize Terraform**:

   ```bash
   cd terraform_dev_local
   terraform init
   ```

2. **Configure Components**:

   Edit `terraform.auto.tfvars` to enable or disable the components you need:

   ```terraform
   # Active components
   cert_manager_enabled = true
   external_secrets_enabled = true
   opentelemetry_enabled = true
   istio_enabled = true
   cnpg_enabled = true
   
   # Inactive components
   # external_dns_enabled = true
   # datadog_enabled = true
   # telepresence_enabled = true
   # argocd_enabled = true
   ```

3. **Activate Component Configuration Files**:

   Some components have their Terraform files marked as inactive with a `.inactive` extension.
   When enabling such components, you need to activate their configuration files:

   ```bash
   # To enable a component with an inactive file (example: external-secrets)
   cp helm_external_secrets.tf.inactive helm_external_secrets.tf
   
   # To disable a currently active component
   mv helm_component_name.tf helm_component_name.tf.inactive
   ```

   This step is important because the `.tf` files contain the actual Helm chart deployment
   configurations, while the variables in `terraform.auto.tfvars` control whether these 
   deployments should be active.

4. **Apply Configuration**:

   ```bash
   terraform apply
   ```

5. **Verify Installation**:

   ```bash
   kubectl get pods --all-namespaces
   ```

6. **Clean Up When Done**:

   ```bash
   # Set teardown = true in terraform.auto.tfvars
   terraform apply
   ```

## How Developers Can Use It

### Component Selection and Configuration

Developers can easily enable or disable components by modifying the `terraform.auto.tfvars` file. This modular approach lets developers pick only the components they need for their specific development scenario.

### Local Kubernetes Integration

The setup is designed to work with Colima (a lightweight Kubernetes environment for macOS) through the `kubernetes_context` variable, allowing developers to:

- Run a production-like Kubernetes environment locally
- Test containerized applications in an environment similar to production
- Learn and experiment with Kubernetes features without affecting shared environments

### Development Workflow Support

Several components specifically enhance the development workflow:

- **Telepresence**: Allows developers to run a single service locally while connecting to a remote Kubernetes cluster
- **Istio**: Provides advanced traffic routing capabilities useful for testing microservices
- **Cert Manager**: Handles SSL certificates, including for local development
- **Argo CD**: Enables GitOps workflow for continuous deployment

### Observability Tools

The setup includes tools for monitoring and debugging:

- **OpenTelemetry**: For distributed tracing and metrics collection
- **Istio**: Provides service mesh monitoring

## Benefits for Containerized Application Development

1. **Consistency**: Every developer gets the same environment with the same versions of components

2. **Modularity**: Only deploy what you need for your specific development task

3. **Local Testing**: Test integrations with production-like services locally

4. **Learning Tool**: Great way to learn Kubernetes and related ecosystem tools

5. **Infrastructure as Code**: Environment setup is documented and reproducible

6. **Rapid Onboarding**: New team members can quickly get a development environment matching the team's setup

## Practical Tips for Developers

1. **Start Small**: Begin with just the components you need (e.g., just cert-manager and istio)

2. **Learn the Tools**: Use this as an opportunity to understand Kubernetes ecosystem tools

3. **Extend as Needed**: The modular design makes it easy to add more components as your applications grow

4. **Use Template Files**: The setup uses template files in the `helm_values` directory that can be customized

5. **Version Control**: Keep your local configurations in version control to track changes and share with team members

## Troubleshooting

### Common Issues

- **Helm Chart Version Conflicts**: If you encounter version conflicts, check the specific Helm chart version in the corresponding `.tf` file.
- **Kubernetes Context Issues**: Ensure your `kubernetes_context` variable in `terraform.auto.tfvars` matches your actual Kubernetes context.
- **Resource Limitations**: Local Kubernetes clusters may have resource limitations. Adjust your component selection accordingly.

### Tips

- Some components may need to be applied twice due to dependency resolution issues
- Check component-specific logs with `kubectl logs -n <namespace> <pod-name>`
- Refer to the official documentation for each component for detailed configuration options

## Contributing

Feel free to enhance this Terraform configuration with additional components or improvements. Please follow the existing file structure and naming conventions.

## License

This project is licensed under the terms of the Apache 2.0 license.

# Terraform Development Local Infrastructure

This directory contains infrastructure as code (IaC) managed by Terraform.

## Workflow

Infrastructure as code uses native Terraform workflows directly:

1. **Initialize**: One-time setup of your Terraform environment
   ```
   cd terraform_dev_local
   terraform init
   ```

2. **Plan**: Preview changes before applying
   ```
   terraform plan
   ```

3. **Apply**: Apply the infrastructure changes
   ```
   terraform apply
   ```

4. **Verify**: Ensure the deployed resources are working correctly
   ```
   terraform output [output-name]
   ```

5. **Clean Up**: When needed, destroy the created resources
   ```
   terraform destroy
   ```

## Project Structure

- `main.tf` - Entry point for infrastructure definition
- `modules/` - Reusable Terraform modules
- `variables.tf` - Input variable definitions
- `outputs.tf` - Output variable definitions
- `terraform.tfvars` - Variable values for local development

## Feature Parity

This Terraform implementation maintains feature parity with the Pulumi implementation in `pulumi_dev_local`.

## Note

- Infrastructure as code uses its own native workflows and does NOT use Skaffold or Bazel
- Application deployment is handled separately using application-specific workflows

## Component Details

### External Secrets

The External Secrets Operator (ESO) is a Kubernetes operator that integrates external secret management systems with Kubernetes. This implementation includes:

- **External Secrets Operator** (v0.14.4): Core operator to manage external secrets
- **Fake Secret Stores**: Simulated secret stores for development purposes:
  - **Cloudflare Secret Store**: Created conditionally when both `external_secrets_enabled` and `external_dns_enabled` are set to `true`
  - **Datadog Secret Store**: Created conditionally when both `external_secrets_enabled` and `datadog_enabled` are set to `true`

External Secrets automatically creates Kubernetes secrets by fetching values from the configured secret stores. This implementation:

1. Deploys the External Secrets Operator using the official Helm chart
2. Creates secret stores for development purposes (no external secret management system needed)
3. Configures ExternalSecret resources that fetch values from these stores

#### Configuration

In `terraform.auto.tfvars`:

```terraform
# Enable/disable the entire External Secrets component
external_secrets_enabled = true
# Enable/disable Cloudflare integration (affects Cloudflare secret store creation)
external_dns_enabled = false
# Enable/disable Datadog integration (affects Datadog secret store creation)
datadog_enabled = false
# Secret values used in the fake secret stores
cloudflare_api_token = "your-api-token"
datadog_api_key = "your-api-key"
datadog_app_key = "your-app-key"
```

When using External Secrets with External DNS, the ExternalSecret automatically creates a Kubernetes secret containing the Cloudflare API token that External DNS uses for DNS record management. Similarly, when Datadog is enabled, it creates a secret with Datadog credentials. 

With the recommended configuration above, the External Secrets Operator will be installed, but no secret stores will be created since both `external_dns_enabled` and `datadog_enabled` are set to `false`. 

## Redis for Istio Rate Limiting

The Bitnami Redis Helm chart is included to support rate limiting in Istio. By default, this chart is disabled but can be enabled for testing and validation of rate limiting functionalities.

### Usage

1. Enable Redis by setting `redis_enabled = true` in `terraform.auto.tfvars`
2. Apply the configuration with `terraform apply`

Redis will be deployed in the `istio-system` namespace and configured for use with Istio's rate limiting service.

### Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| redis_enabled | Enable or disable Redis deployment | false |
| redis_password | Password for Redis authentication | "redis-password" |

### Testing Rate Limiting

After deploying Redis, you can validate the rate limiting functionality by:

```bash
# Test connection to Redis
kubectl exec -it -n istio-system deploy/redis-master -- redis-cli -a $(kubectl get secret -n istio-system redis -o jsonpath="{.data.redis-password}" | base64 --decode)

# Verify rate limiting is working in the template-fastapi-app
skaffold verify -m template-fastapi-app -p istio-rate-limit
```