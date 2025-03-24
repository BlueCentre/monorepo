# Pulumi Local Development Environment

[![Pulumi](https://img.shields.io/badge/pulumi-%235C4EE5.svg?style=for-the-badge&logo=pulumi&logoColor=white)](https://www.pulumi.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Colima](https://img.shields.io/badge/colima-local_k8s-blue?style=for-the-badge)](https://github.com/abiosoft/colima)
[![Go](https://img.shields.io/badge/go-%2300ADD8.svg?style=for-the-badge&logo=go&logoColor=white)](https://golang.org/)

A Pulumi Go-based toolkit for provisioning and managing essential Kubernetes components for local containerized application development.

## Overview

This directory contains a comprehensive Pulumi implementation written in Go, designed to provision and manage essential Kubernetes components for containerized application development in a local environment (specifically using Colima). This setup provides a consistent, reproducible way to deploy commonly used infrastructure components that support modern application development workflows.

The Go implementation offers improved type safety, enhanced error handling, and powerful programmatic control over infrastructure deployment compared to the YAML-based approach, while maintaining the same component feature set and configuration flexibility.

## Key Components Available

The configuration allows developers to selectively enable and deploy:

| Component | Description | Status | Default |
|-----------|-------------|--------|---------|
| **Cert Manager** | Automates the management and issuance of TLS certificates | ✅ Active | ✅ Enabled |
| **Istio** | Complete service mesh with Base, CNI, Control Plane, and Ingress Gateway | ✅ Active | ✅ Enabled |
| **OpenTelemetry** | Observability stack with Operator and Collector for metrics, tracing, and logging | ✅ Active | ✅ Enabled | 
| **External Secrets** | Integration with external secret management systems | ✅ Active | ✅ Enabled |
| **CloudNativePG** | Kubernetes operator for PostgreSQL database clusters | ✅ Active | ✅ Enabled |
| **Argo CD** | GitOps continuous delivery tool | ✅ Active | ❌ Disabled |
| **Telepresence** | Local development tool for remote Kubernetes connections | ✅ Active | ❌ Disabled |
| **External DNS** | Automated DNS configuration for Kubernetes services | ✅ Active | ❌ Disabled |
| **Datadog** | Application monitoring and analytics platform | ✅ Active | ❌ Disabled |
| **Monitoring** | Prometheus and Grafana stack for metrics monitoring | ✅ Active | ❌ Disabled |

**Note**: "Active" status means the component is implemented and ready to use. The "Default" column indicates whether the component is enabled by default in the current configuration. Engineers can enable disabled components by setting their respective flags to `"true"` in `Pulumi.dev.yaml`.

## Modular Structure

The Pulumi configuration has been organized in a modular way to improve maintainability and readability:

```
pulumi_dev_local/
├── main.go                # Main Go program entry point
├── Pulumi.yaml            # Project configuration
├── Pulumi.dev.yaml        # Stack configuration
├── go.mod                 # Go module definition
├── go.sum                 # Go module dependencies
├── COMPONENTS.md          # Detailed component documentation
├── docs/                  # Additional documentation
├── values/                # Helm chart values YAML files
│   ├── cert-manager.yaml  # Cert Manager values
│   ├── external-dns.yaml  # External DNS values
│   ├── external-secrets.yaml # External Secrets values
│   ├── istio.yaml         # Istio values
│   ├── monitoring.yaml    # Prometheus/Grafana values
│   ├── cnpg.yaml          # CloudNativePG values
│   └── datadog.yaml       # Datadog values
└── pkg/                   # Go package directory
    ├── applications/      # Individual component implementations
    │   ├── argocd.go      # Argo CD component
    │   ├── cert_manager.go # Cert Manager component
    │   ├── cnpg.go        # CloudNativePG component
    │   ├── datadog.go     # Datadog component
    │   ├── external_dns.go # External DNS component
    │   ├── external_secrets.go # External Secrets component
    │   ├── external_secrets_store.go # Secret store utilities
    │   ├── ingress.go     # Ingress component
    │   ├── istio.go       # Istio component
    │   ├── monitoring.go  # Monitoring component
    │   ├── opentelemetry.go # OpenTelemetry component
    │   ├── telepresence.go # Telepresence component
    │   └── utils.go       # Shared utilities
    ├── resources/         # Kubernetes resource definitions
    └── utils/             # Utility functions
```

### Helm Values Management

This project uses external YAML files for managing Helm chart values, located in the `values/` directory. This approach offers several benefits:

1. **Separation of Configuration**: Keeps Helm values separate from deployment logic
2. **Improved Maintainability**: Makes it easier to update and maintain values without changing code
3. **Consistency**: Uses the same format and structure across all components
4. **Portability**: Values can be reused with other IaC tools if needed

Each component in `pkg/applications/` automatically loads values from its corresponding YAML file when deployed. Runtime overrides can still be applied when needed.

For more details on our Helm best practices, see [Pulumi Helm Best Practices](./docs/pulumi_helm_best_practices.md).

### Enabling and Disabling Components

This Pulumi setup allows you to easily enable or disable components through configuration:

1. **Update Pulumi.dev.yaml**:
   
   The `Pulumi.dev.yaml` file contains the configuration for each component:

   ```yaml
   config:
     dev-local-infrastructure:cert_manager_enabled: "true"
     dev-local-infrastructure:opentelemetry_enabled: "true"
     dev-local-infrastructure:istio_enabled: "true"
     dev-local-infrastructure:external_secrets_enabled: "true"
     dev-local-infrastructure:external_dns_enabled: "false"
     dev-local-infrastructure:datadog_enabled: "false"
     # dev-local-infrastructure:argocd_enabled: "true"  # Uncomment to enable
   ```

   Set a component to `"true"` to enable it or `"false"` to disable it.

### Go-Based Implementation

This Pulumi configuration uses Go as the implementation language, providing several benefits:

1. **Type Safety**: Go's strong typing helps prevent configuration errors.
2. **Better Modularity**: Each component is defined in its own Go file in the `pkg/applications/` directory.
3. **Advanced Logic**: Complex conditional logic can be implemented for component deployments.
4. **Better Testability**: Go code can be tested with standard testing frameworks.
5. **Extended Functionality**: Direct access to the Kubernetes API server when needed.

### Customizing Components

To customize a component:

1. Edit the relevant component file in the `pkg/applications/` directory
2. Modify the corresponding values YAML file in the `values/` directory
3. Run `pulumi preview` to see the changes
4. Apply the changes with `pulumi up`

For example, to customize the Istio component:

1. Edit `pkg/applications/istio.go` to modify deployment logic
2. Edit `values/istio.yaml` to change Helm values
3. Run `pulumi preview` to verify changes
4. Run `pulumi up` to apply changes

### Adding a New Component

To add a new component:

1. Create a new Go file in the `pkg/applications/` directory
2. Create a new values YAML file in the `values/` directory if needed
3. Add the component initialization to `main.go`
4. Add appropriate configuration options to `Pulumi.dev.yaml`
5. Preview and apply the changes

For example, to add a new component called "example-component":

1. Create `pkg/applications/example_component.go`
2. Create `values/example-component.yaml` with Helm values
3. Update `main.go` to include the new component
4. Add `dev-local-infrastructure:example_component_enabled: "true"` to `Pulumi.dev.yaml`
5. Run `pulumi preview` and `pulumi up`

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
     dev-local-infrastructure:cert_manager_enabled: "true"
     dev-local-infrastructure:opentelemetry_enabled: "true"
     dev-local-infrastructure:istio_enabled: "true"
     dev-local-infrastructure:external_secrets_enabled: "true"
     dev-local-infrastructure:external_dns_enabled: "false"
     dev-local-infrastructure:datadog_enabled: "false"
     # dev-local-infrastructure:argocd_enabled: "true"  # Uncomment to enable
   ```

4. **Preview the Deployment**:

   ```bash
   pulumi preview
   ```

5. **Deploy Resources**:

   ```bash
   pulumi up
   ```

6. **Verify Installation**:

   ```bash
   kubectl get pods --all-namespaces
   ```

7. **Clean Up When Done**:

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
   
   # Export the stack** with the new passphrase:
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

## External Secrets and External DNS

The Pulumi configuration includes External Secrets (version 0.14.4) and External DNS (version 1.15.0) Helm charts, matching the versions used in the terraform_dev_local configuration.

### External Secrets Operator

External Secrets Operator is installed with the following configuration:
- Installs CRDs
- Creates ClusterExternalSecret and ClusterSecretStore CRDs
- Creates a service account for the operator
- Disables webhook and cert controller for local development

**Note:** With the current configuration, External Secrets Operator is enabled (`external_secrets_enabled: "true"`), but no secret stores will be created since both `external_dns_enabled` and `datadog_enabled` are set to `"false"`.

### External DNS

External DNS is configured to:
- Use Cloudflare as the provider
- Pull API token from a Kubernetes secret (cf-secret)
- Use bluecentre-dev as the TXT owner ID
- Sync records with a 30-minute interval
- Only process resources with the annotation `external-dns.alpha.kubernetes.io/sync-enabled: "true"`
- Monitor istio-gateway resources for DNS entries

**Note:** External DNS is currently disabled in the configuration (`external_dns_enabled: "false"`).

### Manual Post-Deployment Steps

If you decide to enable External DNS (`external_dns_enabled: "true"`), you would need to manually create the following resources after deployment:

1. A ClusterSecretStore to serve as a fake secret provider:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: external-secret-cluster-fake-secrets
  namespace: external-secrets
spec:
  provider:
    fake:
      data:
      - key: "CLOUDFLARE_API_TOKEN"
        value: "REPLACE_WITH_CLOUDFLARE_API_TOKEN"
        version: "v1"
```

2. An ExternalSecret to retrieve the Cloudflare API token:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: cf-external-secret
  namespace: external-dns
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: external-secret-cluster-fake-secrets
  target:
    name: cf-secret
    creationPolicy: Owner
    template:
      metadata:
        labels:
          service: external-dns
        annotations:
          reloader.stakater.com/match: "true"
  data:
    - secretKey: cloudflare-api-key
      remoteRef:
        key: CLOUDFLARE_API_TOKEN
        version: v1
```

These resources can be applied using `kubectl apply -f <filename>` after enabling and deploying the External DNS component.

Alternatively, you would use the provided post-deployment script after enabling the component:

```bash
# First update the configuration and deploy with Pulumi
# Edit Pulumi.dev.yaml to set external_dns_enabled: "true"
pulumi up

# Then run the post-deployment script
./post-deploy.sh
```

The script will create the necessary custom resources for external-secrets and external-dns integration.

### Enabling Components in Your Configuration

To enable External DNS or Datadog integration with External Secrets, update the `Pulumi.dev.yaml` file:

```yaml
config:
  # Enable External DNS integration (will create Cloudflare secret store)
  dev-local-infrastructure:external_dns_enabled: "true"
  
  # Enable Datadog integration (will create Datadog secret store)
  dev-local-infrastructure:datadog_enabled: "true"
```

Then run `pulumi up` to apply the changes.