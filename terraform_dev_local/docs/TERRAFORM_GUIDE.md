# Terraform Usage and Details Guide

This guide provides details on using the Terraform setup for the local development environment, including workflow, structure, tips, and component specifics.

## How Developers Can Use It

### Component Selection and Configuration

Developers can easily enable or disable components by modifying the `terraform.auto.tfvars` file. This modular approach lets developers pick only the components they need for their specific development scenario.

Component Terraform files (e.g., `helm_external_secrets.tf`) might be suffixed with `.inactive`. To enable such a component, ensure the corresponding variable in `terraform.auto.tfvars` is set to `true` AND rename the file by removing the `.inactive` extension (e.g., `mv helm_external_secrets.tf.inactive helm_external_secrets.tf`). Conversely, to disable an active component, set its variable to `false` and rename its `.tf` file to `.tf.inactive`.

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
- **Apply Twice**: Some components, particularly those with complex dependencies or CRD installations, might require running `terraform apply` a second time to fully reconcile.

### Tips

- Check component-specific logs with `kubectl logs -n <namespace> <pod-name>`
- Refer to the official documentation for each component for detailed configuration options

## Terraform Workflow

This infrastructure uses native Terraform commands directly:

1. **Initialize**: One-time setup of your Terraform environment. Downloads providers and modules.
   ```bash
   cd terraform_dev_local
   terraform init
   ```

2. **Plan**: Preview changes before applying. Shows what resources will be created, modified, or destroyed.
   ```bash
   terraform plan
   ```

3. **Apply**: Apply the infrastructure changes described in the plan.
   ```bash
   terraform apply # You will be prompted for confirmation
   # OR
   terraform apply -auto-approve # Apply without interactive confirmation
   ```

4. **Verify**: Ensure the deployed resources are working correctly. Check outputs or use `kubectl`.
   ```bash
   terraform output [output-name]
   kubectl get pods -n <component-namespace>
   ```

5. **Clean Up**: When needed, destroy the created resources.
   ```bash
   terraform destroy # You will be prompted for confirmation
   # OR
   terraform destroy -auto-approve # Destroy without interactive confirmation
   ```

## Project Structure

- `main.tf`: Entry point, defines providers and calls component modules/resources.
- `helm_*.tf` / `helm_*.tf.inactive`: Contains `helm_release` resources for each component.
- `variables.tf`: Input variable definitions (e.g., `*_enabled` flags, versions, context).
- `outputs.tf`: Output variable definitions (if any).
- `terraform.auto.tfvars`: Variable values automatically loaded by Terraform.
- `helm_values/`: Directory containing YAML template files used for Helm chart values.
- `docs/`: Contains detailed documentation files.
- `versions.tf`: Defines required provider versions.

## Feature Parity

This Terraform implementation aims to maintain feature parity with the Pulumi implementation in `pulumi_dev_local/` regarding the available components and their core functionalities.

## Note on Build/Deploy Tools

- This Terraform setup manages the underlying Kubernetes infrastructure components.
- It uses its own native workflows (`terraform plan/apply/destroy`) and does **NOT** use Skaffold or Bazel.
- Application deployment onto the provisioned Kubernetes cluster is handled separately using application-specific workflows (likely involving Skaffold/Bazel as defined elsewhere in the monorepo).

## Component Details Extract (Example: External Secrets)

*(Note: For full details on all components, see `docs/COMPONENTS.md`)*

### External Secrets

The External Secrets Operator (ESO) integrates external secret management systems with Kubernetes. This Terraform setup includes:

- **External Secrets Operator Helm Release**: Deploys ESO version `0.14.4`.
- **Fake Secret Stores**: Creates `kubernetes_manifest` resources for simulated `ClusterSecretStore` objects for development purposes:
  - **Cloudflare Secret Store**: Created conditionally if `external_secrets_enabled && external_dns_enabled`.
  - **Datadog Secret Store**: Created conditionally if `external_secrets_enabled && datadog_enabled`.

#### Configuration (`terraform.auto.tfvars`)

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

When dependent components like External DNS or Datadog are enabled alongside External Secrets, ESO automatically creates Kubernetes secrets (e.g., `cf-secret`, `datadog-secret`) by fetching values from these fake stores. The respective components then use these Kubernetes secrets. 