# Terraform Local Development Environment

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Colima](https://img.shields.io/badge/colima-local_k8s-blue?style=for-the-badge)](https://github.com/abiosoft/colima)

A Terraform-based toolkit for provisioning and managing essential Kubernetes components for local containerized application development.

## Overview

This directory contains a comprehensive set of Terraform configurations designed to provision and manage essential Kubernetes components for containerized application development in a local environment (specifically using Colima). This setup provides a consistent, reproducible way to deploy commonly used infrastructure components that support modern application development workflows.

This Terraform implementation maintains feature parity with the Pulumi implementation in `../pulumi_dev_local`.

## Key Components Available

For a detailed list of components, their status, and configuration options, please see:

- [Component Details](./docs/COMPONENTS.md)

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

   Edit `terraform.auto.tfvars` to enable or disable the components you need. Refer to `variables.tf` for available options.

   ```terraform
   # Example enabling components
   cert_manager_enabled = true
   istio_enabled = true
   # ... etc ...
   ```
   *Note: Also ensure corresponding `.tf` files are active (not named `.tf.inactive`). See the Terraform Guide for details.* 

3. **Apply Configuration**:

   ```bash
   terraform apply
   ```

4. **Verify Installation**:

   ```bash
   kubectl get pods --all-namespaces
   ```

5. **Clean Up When Done**:

   ```bash
   terraform destroy
   ```

## Further Information

For more detailed information on usage, workflow, tips, troubleshooting, and project structure, please refer to:

- [Terraform Usage and Details Guide](./docs/TERRAFORM_GUIDE.md)

For guidance on contributing complex components (applying to both Terraform and Pulumi), see:

- [Contributing Complex IAC Components](../../docs/CONTRIBUTING_COMPLEX_IAC_COMPONENTS.md)

## Contributing

Feel free to enhance this Terraform configuration with additional components or improvements. Please follow the existing file structure and naming conventions. Refer to the contribution guides linked above.

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