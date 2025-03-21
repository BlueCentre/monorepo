# Pulumi Local Development Environment

[![Pulumi](https://img.shields.io/badge/pulumi-%235C4EE5.svg?style=for-the-badge&logo=pulumi&logoColor=white)](https://www.pulumi.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Colima](https://img.shields.io/badge/colima-local_k8s-blue?style=for-the-badge)](https://github.com/abiosoft/colima)

A Pulumi YAML-based toolkit for provisioning and managing essential Kubernetes components for local containerized application development.

## Overview

This directory contains a comprehensive set of Pulumi YAML configurations designed to provision and manage essential Kubernetes components for containerized application development in a local environment (specifically using Colima). This setup provides a consistent, reproducible way to deploy commonly used infrastructure components that support modern application development workflows.

## Key Components Available

The configuration allows developers to selectively enable and deploy:

| Component | Description | Status |
|-----------|-------------|--------|
| **Cert Manager** | Automates the management and issuance of TLS certificates | ✅ Active |
| **Istio** | Complete service mesh with Base, CNI, Control Plane, and Ingress Gateway | ✅ Active |
| **OpenTelemetry** | Observability stack with Operator and Collector for metrics, tracing, and logging | ✅ Active | 
| **Argo CD** | GitOps continuous delivery tool | ✅ Active |
| **Telepresence** | Local development tool for remote Kubernetes connections | ✅ Active |
| **External Secrets** | Integration with external secret management systems | 🔄 Inactive |
| **External DNS** | Automated DNS configuration | 🔄 Inactive |
| **Datadog** | Application monitoring and analytics | 🔄 Inactive |

## Modular Structure

The Pulumi configuration has been organized in a modular way to improve maintainability and readability:

```
pulumi_dev_local/
├── Pulumi.yaml             # Project configuration
├── Pulumi.dev.yaml         # Stack configuration
├── main.yaml               # Main configuration file (assembled from components)
├── build.sh                # Script to build main.yaml from components
├── components/             # Directory for component files
│   ├── cert-manager.yaml   # Cert Manager component
│   ├── opentelemetry.yaml  # OpenTelemetry component
│   ├── istio.yaml          # Istio component
│   ├── argocd.yaml         # Argo CD component
│   └── telepresence.yaml   # Telepresence component
└── README.md               # Documentation
```

### Components System

Each Kubernetes component is defined in its own YAML file in the `components` directory. This modular approach provides several benefits:

1. **Improved Readability**: Each component's configuration is in its own file, making it easier to understand.
2. **Better Maintainability**: Updates to a single component only require changes to that component's file.
3. **Simplified Addition of New Components**: Adding a new component involves creating a new file in the components directory.

### Building the Configuration

The `build.sh` script assembles the final `main.yaml` configuration by combining the individual component files:

```bash
# Build the configuration
./build.sh

# Preview the result
pulumi preview
```

The script reads the component files and creates a unified configuration file that includes all the enabled components. This approach allows for:

1. **Selective Component Inclusion**: Components can be conditionally included based on configuration.
2. **Consistent Structure**: All components follow the same structure and naming conventions.
3. **Simplified Maintenance**: Changes to a component only require updating a single file.

### Customizing Components

To customize a component:

1. Edit the relevant component file in the `components` directory
2. Run `./build.sh` to rebuild the main configuration
3. Run `pulumi preview` to see the changes
4. Apply the changes with `pulumi up`

### Adding a New Component

To add a new component:

1. Create a new YAML file in the `components` directory following the existing pattern
2. Add the component to the `build.sh` script
3. Run `./build.sh` to rebuild the main configuration
4. Preview and apply the changes

## Getting Started

### Prerequisites

- [Pulumi CLI](https://www.pulumi.com/docs/install/) (latest version)
- [Colima](https://github.com/abiosoft/colima) or another local Kubernetes environment
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) configured to work with your local cluster

### Quick Start

1. **Initialize Pulumi**:

   ```bash
   cd pulumi_dev_local
   pulumi login --local
   pulumi stack init dev
   ```

2. **Set a Passphrase for Configuration Encryption**:

   ```bash
   export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"
   ```

3. **Configure Components**:

   Edit `Pulumi.dev.yaml` to enable the components you need:

   ```yaml
   config:
     pulumi-dev-local:certManagerEnabled: true
     pulumi-dev-local:openTelemetryEnabled: true
     pulumi-dev-local:istioEnabled: true
     # pulumi-dev-local:argocdEnabled: true  # Uncomment to enable
   ```

4. **Build the Configuration**:

   ```bash
   # Make the build script executable if needed
   chmod +x build.sh
   
   # Build the configuration from components
   ./build.sh
   ```

5. **Preview the Deployment**:

   ```bash
   pulumi preview
   ```

6. **Deploy Resources**:

   ```bash
   pulumi up
   ```

7. **Verify Installation**:

   ```bash
   kubectl get pods --all-namespaces
   ```

8. **Clean Up When Done**:

   ```bash
   # Set teardown = true in Pulumi.dev.yaml
   pulumi up
   
   # OR to completely destroy all resources
   pulumi destroy
   ```

## Managing the Pulumi Passphrase

Pulumi uses a passphrase to encrypt sensitive configuration values. Here's how to manage it:

### Setting the Passphrase

The passphrase can be set in several ways:

1. **Environment Variable** (recommended for development):
   ```bash
   export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"
   ```

2. **Passphrase File** (recommended for CI/CD):
   ```bash
   echo "your-secure-passphrase" > ~/.pulumi/passphrase.txt
   export PULUMI_CONFIG_PASSPHRASE_FILE=~/.pulumi/passphrase.txt
   ```

### Changing the Passphrase

To change the passphrase for an existing stack:

1. **Export the current stack** with the old passphrase:
   ```bash
   # Set the old passphrase
   export PULUMI_CONFIG_PASSPHRASE="old-passphrase"
   
   # Export the stack to a file
   pulumi stack export --file stack.json
   ```

2. **Import the stack** with the new passphrase:
   ```bash
   # Set the new passphrase
   export PULUMI_CONFIG_PASSPHRASE="new-passphrase"
   
   # Import the stack from the file
   pulumi stack import --file stack.json
   ```

3. **Verify the stack** is working with the new passphrase:
   ```bash
   pulumi preview
   ```

4. **Clean up** by removing the temporary file:
   ```bash
   rm stack.json
   ```

### Best Practices for Passphrase Management

1. **Use a Strong Passphrase**: Choose a secure, randomly generated passphrase.
2. **Don't Commit the Passphrase**: Never store the passphrase in version control.
3. **Use Different Passphrases** for different environments (dev, staging, production).
4. **Rotate Passphrases** periodically for enhanced security.
5. **Use a Password Manager** to store and manage passphrases securely.
6. **Document the Procedure** for passphrase recovery within your team.

### Troubleshooting Passphrase Issues

If you encounter passphrase-related errors:

- **"failed to decrypt"**: You're using the wrong passphrase. Make sure you're using the correct passphrase for the stack.
- **"passphrase must be set"**: You haven't set the PULUMI_CONFIG_PASSPHRASE environment variable.
- **Lost passphrase**: If you've lost the passphrase, you'll need to create a new stack and manually recreate your resources.

## Non-Interactive Deployments

When running Pulumi in CI/CD pipelines or other automated environments, you'll want to execute deployments without requiring interactive confirmation.

### Why `pulumi up -y` May Not Work

The standard `pulumi up -y` command may not work as expected with Pulumi YAML due to:

1. YAML language runtime handling flags differently than programming language SDKs
2. Passphrase and authentication challenges in non-interactive environments
3. State file conflicts requiring user input

### Non-Interactive Deployment Options

#### Environment Variable Method

```bash
# Set environment variables for non-interactive use
export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"
export PULUMI_SKIP_CONFIRMATIONS=true

# Run normal command (no -y needed)
pulumi up
```

#### Skip Preview Method

```bash
# Skip the preview and go straight to deployment
export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"
pulumi up --skip-preview
```

#### Using Shell Pipe

```bash
# Pipe "yes" to automatically accept prompts
export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"
yes | pulumi up
```

### Troubleshooting Non-Interactive Deployments

If you're still having issues with non-interactive deployments:

1. **Check for Pending Operations**:
   ```bash
   pulumi cancel
   ```

2. **Ensure Stack is Selected**:
   ```bash
   pulumi stack select dev
   ```

3. **Verify Permissions**:
   Ensure the user running the command has the necessary permissions.

4. **Debug with Verbose Logging**:
   ```bash
   pulumi up --verbose=3
   ```

5. **Check for State Lock**:
   In rare cases, you may need to force unlock the state:
   ```bash
   pulumi cancel --force
   ```

For CI/CD pipelines, it's recommended to use a service account with appropriate permissions and a securely stored passphrase.

## Deployed Components Details

For a comprehensive guide to all the components available and their configuration details, see the [COMPONENTS.md](./COMPONENTS.md) file.

### Cert Manager

**Status**: ✅ Active
**Version**: v1.17.0
**Namespace**: cert-manager

Cert Manager provides automated certificate management capabilities in Kubernetes:
- Automates the issuance and renewal of TLS certificates
- Supports multiple issuers including Let's Encrypt, Vault, and self-signed certificates
- Simplifies certificate management for Kubernetes services and ingresses

### OpenTelemetry

**Status**: ✅ Active  
**Components**:
- OpenTelemetry Operator (v0.79.0)
- OpenTelemetry Collector (v0.79.0)
**Namespace**: opentelemetry

The OpenTelemetry deployment includes:
- **OpenTelemetry Operator**: Manages OpenTelemetry Collector instances and instrumentation
- **OpenTelemetry Collector**: Collects, processes, and exports telemetry data
- Support for collecting metrics, traces, and logs from applications
- Integration with various backends and observability tools

### Istio

**Status**: ✅ Active  
**Version**: 1.23.3  
**Components**:
- Istio Base
- Istio CNI
- Istio Control Plane (istiod)
- Istio Ingress Gateway
**Namespace**: istio-system

The complete Istio deployment provides:
- **Service Mesh Capabilities**: Traffic management, security, and observability
- **Istio CNI**: Network management without privileged init containers
- **Istio Control Plane**: Core service mesh functionality
- **Istio Ingress Gateway**: External traffic management with:
  - HTTP port: 80 (targeting 8080)
  - HTTPS port: 443 (targeting 8443)
  - Service type: ClusterIP (for local development)

The Ingress Gateway can be accessed locally through port-forwarding:
```bash
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
```

## How Developers Can Use It

### Component Selection and Configuration

Developers can easily enable or disable components by modifying the `Pulumi.dev.yaml` file. This modular approach lets developers pick only the components they need for their specific development scenario.

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

4. **Use YAML Configuration**: The setup uses YAML configuration which is easy to understand and modify

5. **Version Control**: Keep your local configurations in version control to track changes and share with team members

## Differences from Terraform Implementation

This Pulumi implementation offers the same functionality as the Terraform version with some key differences:

1. **YAML-Based**: Uses Pulumi's YAML language for improved readability and simplicity
2. **Standard Kubernetes Resources**: Leverages Pulumi's native Kubernetes provider
3. **Simplified Dependencies**: More straightforward dependency management
4. **Native Conditionals**: Uses Pulumi's built-in conditional support for resource creation

## Troubleshooting

### Common Issues

- **Passphrase Required**: Pulumi requires a passphrase for configuration encryption. Set it using the `PULUMI_CONFIG_PASSPHRASE` environment variable. See the [Managing the Pulumi Passphrase](#managing-the-pulumi-passphrase) section for detailed instructions.
- **YAML Format Issues**: Ensure your YAML syntax is correct. Pulumi YAML has specific formatting requirements.
- **Helm Chart Version Conflicts**: If you encounter version conflicts, check the specific Helm chart version in the `main.yaml` file.
- **Kubernetes Context Issues**: Ensure your `kubernetesContext` variable in `Pulumi.dev.yaml` matches your actual Kubernetes context.
- **Resource Limitations**: Local Kubernetes clusters may have resource limitations. Adjust your component selection accordingly.

### Tips

- Check component-specific logs with `kubectl logs -n <namespace> <pod-name>`
- Use `pulumi preview` to see what changes will be made before applying them
- Refer to the official documentation for each component for detailed configuration options

## Contributing

Feel free to enhance this Pulumi configuration with additional components or improvements. Please follow the existing file structure and naming conventions.

## License

This project is licensed under the terms of the Apache 2.0 license. 