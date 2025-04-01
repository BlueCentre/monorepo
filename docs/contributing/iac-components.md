# Contributing Infrastructure Components

This guide provides comprehensive instructions for adding new Helm charts and infrastructure components to both Terraform and Pulumi implementations in our monorepo for local development of containerized applications.

## Table of Contents

- [Overview](#overview)
- [Step-by-Step Implementation Guide](#step-by-step-implementation-guide)
  - [1. Initial Planning](#1-initial-planning)
  - [2. Adding Configuration Options](#2-adding-configuration-options)
  - [3. Creating the Helm Release Resource](#3-creating-the-helm-release-resource)
  - [4. Adding Values File](#4-adding-values-file)
  - [5. Adding Component References in Main Files](#5-adding-component-references-in-main-files)
  - [6. Adding Integration with Other Components](#6-adding-integration-with-other-components)
  - [7. Updating Documentation](#7-updating-documentation)
  - [8. Testing Your Implementation](#8-testing-your-implementation)
  - [9. Cleaning Up](#9-cleaning-up)
- [Best Practices](#best-practices)
- [Example: Redis Implementation](#example-redis-implementation)

## Overview

Our infrastructure is managed through Infrastructure as Code (IaC) with dual implementations:
- **Terraform**: Located in `terraform_dev_local/`
- **Pulumi**: Located in `pulumi_dev_local/`

We maintain feature parity between both implementations to provide developers with options based on their preferences.

## Step-by-Step Implementation Guide

### 1. Initial Planning

**For both Terraform and Pulumi:**
- Identify the Helm chart you want to add
- Determine the namespace it should be deployed to
- Decide on required configuration values
- Consider dependencies on other components
- Plan for any additional resources needed (CRDs, ConfigMaps, etc.)
- Ensure feature parity between Terraform and Pulumi implementations

### 2. Adding Configuration Options

#### Terraform:
```hcl
# terraform_dev_local/variables.tf
variable "component_enabled" {
  description = "Enable component deployment"
  type        = bool
  default     = false
}

variable "component_namespace" {
  description = "Namespace for component"
  type        = string
  default     = "component-namespace"
}

variable "component_chart_version" {
  description = "Version of component Helm chart to use"
  type        = string
  default     = "1.2.3" # Always specify a specific version
}
```

#### Pulumi:
```yaml
# pulumi_dev_local/Pulumi.dev.yaml (add to existing file)
config:
  dev-local-infrastructure:component_enabled: "true"
  dev-local-infrastructure:component_version: "1.2.3"
```

```go
// In pulumi_dev_local/pkg/utils/config.go or directly in implementation file
componentEnabled := conf.GetBool("component_enabled", false)
version := conf.GetString("component_version", "1.2.3")
```

### 3. Creating the Helm Release Resource

#### Terraform:
```hcl
# terraform_dev_local/helm_component.tf
resource "kubernetes_namespace" "component" {
  count = var.component_enabled ? 1 : 0
  
  metadata {
    name = var.component_namespace
  }
}

resource "helm_release" "component" {
  count            = var.component_enabled ? 1 : 0
  name             = "component"
  namespace        = kubernetes_namespace.component[0].metadata[0].name
  repository       = "https://charts.example.org/stable"
  chart            = "component"
  version          = var.component_chart_version
  timeout          = 600
  create_namespace = true
  
  # Chart specific values
  values = [file("${path.module}/values/component.yaml")]
  
  # Optionally set specific values directly
  set {
    name  = "key"
    value = "value"
  }
  
  # Add dependencies if needed
  depends_on = [
    helm_release.dependency
  ]
}
```

#### Pulumi:
```go
// pulumi_dev_local/pkg/applications/component.go
package applications

import (
    "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
    "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
    "github.com/pulumi/pulumi/sdk/v3/go/pulumi"
    "github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
    
    "github.com/james/monorepo/pulumi_dev_local/pkg/resources"
)

func DeployComponent(ctx *pulumi.Context, provider *kubernetes.Provider) (pulumi.Resource, error) {
    // Get configuration
    conf := config.New(ctx, "dev-local-infrastructure")
    
    // Check if component is enabled
    componentEnabled := conf.GetBoolWithDefault("component_enabled", false)
    if !componentEnabled {
        ctx.Log.Info("Component is disabled, skipping deployment", nil)
        return nil, nil
    }
    
    // Get component configuration
    version := conf.GetWithDefault("component_version", "1.2.3")
    namespace := "component-namespace"
    
    // Create namespace
    ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
        Name: namespace,
    })
    if err != nil {
        return nil, err
    }
    
    // Deploy component helm chart
    componentChart, err := helm.NewRelease(ctx, "component", &helm.ReleaseArgs{
        Chart:           pulumi.String("component"),
        Version:         pulumi.String(version),
        RepositoryOpts:  &helm.RepositoryOptsArgs{
            Repo:        pulumi.String("https://charts.example.org/stable"),
        },
        Namespace:       pulumi.String(namespace),
        CreateNamespace: pulumi.Bool(true),
        Values:          pulumi.Map{
            "key": pulumi.String("value"),
            // Add more values as needed
        },
        Timeout: pulumi.Int(600),
        Wait:    pulumi.Bool(true),
    }, pulumi.Provider(provider), pulumi.DependsOn([]pulumi.Resource{ns}))
    
    return componentChart, err
}
```

### 4. Adding Values File

#### Terraform:
```yaml
# terraform_dev_local/values/component.yaml
# Component values file for Terraform
global:
  imageRegistry: ""
  imagePullSecrets: []

resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "1Gi"
    cpu: "500m"

persistence:
  enabled: true
  size: 10Gi

service:
  type: ClusterIP
  port: 8080
```

#### Pulumi:
For Pulumi, values are typically defined directly in the code as shown above, but you can also load from a YAML file:

```go
// Alternative approach loading from YAML file
yamlFile, err := ioutil.ReadFile("values/component.yaml")
if err != nil {
    return nil, err
}

var values map[string]interface{}
if err := yaml.Unmarshal(yamlFile, &values); err != nil {
    return nil, err
}

componentChart, err := helm.NewRelease(ctx, "component", &helm.ReleaseArgs{
    // ...other args
    Values: pulumi.Map(values),
}, pulumi.Provider(provider), pulumi.DependsOn([]pulumi.Resource{ns}))
```

### 5. Adding Component References in Main Files

#### Terraform:
If using modules:
```hcl
# terraform_dev_local/main.tf
module "component" {
  count  = var.component_enabled ? 1 : 0
  source = "./modules/component"
  
  namespace = var.component_namespace
  version   = var.component_chart_version
  
  depends_on = [
    module.dependency
  ]
}
```

#### Pulumi:
```go
// pulumi_dev_local/main.go
// Add to the main function
if componentEnabled {
    if _, err := applications.DeployComponent(ctx, k8sProvider); err != nil {
        return err
    }
}
```

### 6. Adding Integration with Other Components

If your component needs to integrate with other components, add the integration code:

#### Terraform:
```hcl
# terraform_dev_local/component_integration.tf
resource "kubernetes_manifest" "integration_resource" {
  count = var.component_enabled && var.other_component_enabled ? 1 : 0
  
  manifest = {
    apiVersion = "example.com/v1"
    kind       = "Integration"
    metadata = {
      name      = "component-integration"
      namespace = "integration-namespace"
    }
    spec = {
      componentEndpoint = "${var.component_name}-service.${var.component_namespace}.svc.cluster.local:8080"
      // Additional integration configuration
    }
  }
  
  depends_on = [
    helm_release.component,
    helm_release.other_component
  ]
}
```

#### Pulumi:
```go
// In relevant application file
// Add integration if both components are enabled
componentEnabled := conf.GetBool("component_enabled", false)
otherComponentEnabled := conf.GetBool("other_component_enabled", false)

if componentEnabled && otherComponentEnabled {
    _, err = resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
        Name: "component-integration",
        YAML: `apiVersion: example.com/v1
kind: Integration
metadata:
  name: component-integration
  namespace: integration-namespace
spec:
  componentEndpoint: component-service.component-namespace.svc.cluster.local:8080
  # Additional integration configuration
`,
    }, pulumi.DependsOn([]pulumi.Resource{componentChart, otherComponentChart}))
    if err != nil {
        return err
    }
}
```

### 7. Updating Documentation

Update `terraform_dev_local/COMPONENTS.md` and `pulumi_dev_local/COMPONENTS.md` with information about the new component:

```markdown
## Component Name

**Status**: Active  
**Version**: 1.2.3  
**Namespace**: component-namespace

### Overview
Brief description of the component and its purpose.

### Implementation
- Deployed using XYZ Helm chart
- Key configuration details
- Any special considerations

### Features
- Feature 1
- Feature 2

### Dependencies
- Dependency 1
- Dependency 2

### Configuration Options
- Enable/disable via `component_enabled` (Terraform) or `dev-local-infrastructure:component_enabled` (Pulumi)
- Chart version configurable via `component_chart_version` (Terraform) or `dev-local-infrastructure:component_version` (Pulumi)
- Other configuration options

### Documentation Links
- [Official Documentation](https://example.com/docs)
- [Helm Chart Repository](https://github.com/example/charts)
```

### 8. Testing Your Implementation

#### Terraform:
```bash
# Navigate to terraform directory
cd terraform_dev_local

# Initialize Terraform
terraform init

# Preview the changes
terraform plan -var="component_enabled=true"

# Apply the changes
terraform apply -var="component_enabled=true" -auto-approve

# Verify the deployment
kubectl get pods -n component-namespace
kubectl get svc -n component-namespace
```

#### Pulumi:
```bash
# Navigate to Pulumi directory
cd pulumi_dev_local

# Set configuration
pulumi config set dev-local-infrastructure:component_enabled true
pulumi config set dev-local-infrastructure:component_version 1.2.3

# Preview the changes
pulumi preview

# Apply the changes
pulumi up -y

# Verify the deployment
kubectl get pods -n component-namespace
kubectl get svc -n component-namespace
```

### 9. Cleaning Up

#### Terraform:
```bash
terraform destroy -var="component_enabled=true" -auto-approve
```

#### Pulumi:
```bash
pulumi destroy -y
```

## Best Practices

1. **Version Pinning**: Always pin chart versions to ensure consistency and reproducibility.
2. **Resource Requirements**: Define appropriate resource requests and limits for production-readiness.
3. **Dependencies**: Manage dependencies correctly with `depends_on` to ensure proper installation order.
4. **Documentation**: Keep COMPONENTS.md files updated with detailed information about each component.
5. **Configuration**: Use variables/configs with sensible defaults and appropriate descriptions.
6. **Testing**: Always test your component deployment with both creation and destroy cycles.
7. **Error Handling**: Implement proper error handling, especially in Pulumi code.
8. **Values Organization**: Keep chart values organized in separate files for Terraform or structured blocks in code for Pulumi.
9. **Feature Parity**: Maintain feature parity between Terraform and Pulumi implementations.
10. **Security Considerations**: Follow security best practices, especially for sensitive values.
11. **Timeouts**: Set appropriate timeouts for Helm releases to avoid premature failures.
12. **Idempotency**: Ensure your implementation is idempotent and can be applied multiple times without issues.

## Example: Redis Implementation

Here's a concrete example of implementing Redis using both Terraform and Pulumi:

### Terraform Redis Implementation

```hcl
# terraform_dev_local/helm_redis.tf
resource "kubernetes_namespace" "redis" {
  count = var.redis_enabled ? 1 : 0
  
  metadata {
    name = "redis"
  }
}

resource "helm_release" "redis" {
  count            = var.redis_enabled ? 1 : 0
  name             = "redis"
  namespace        = kubernetes_namespace.redis[0].metadata[0].name
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "redis"
  version          = "18.19.1"
  timeout          = 600
  create_namespace = true
  
  values = [file("${path.module}/values/redis.yaml")]
  
  set {
    name  = "auth.password"
    value = "redis-password"
  }
  
  depends_on = [
    kubernetes_namespace.redis
  ]
}

# If Redis integrates with Istio for rate limiting
resource "kubernetes_manifest" "rate_limit_service" {
  count = var.istio_enabled && var.redis_enabled ? 1 : 0
  
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "EnvoyFilter"
    metadata = {
      name      = "rate-limit-service"
      namespace = "istio-system"
    }
    spec = {
      workloadSelector = {
        labels = {
          istio = "ingressgateway"
        }
      }
      configPatches = [
        {
          applyTo = "CLUSTER"
          match = {
            context = "GATEWAY"
          }
          patch = {
            operation = "ADD"
            value = {
              name            = "rate_limit_service"
              connect_timeout = "10s"
              lb_policy       = "ROUND_ROBIN"
              load_assignment = {
                cluster_name = "rate_limit_service"
                endpoints = [
                  {
                    lb_endpoints = [
                      {
                        endpoint = {
                          address = {
                            socket_address = {
                              address    = "redis-master.redis.svc.cluster.local"
                              port_value = 6379
                            }
                          }
                        }
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      ]
    }
  }
  
  depends_on = [
    helm_release.redis,
    helm_release.istio_ingressgateway
  ]
}
```

### Pulumi Redis Implementation

```go
// pulumi_dev_local/pkg/applications/redis.go
package applications

import (
    "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
    "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
    "github.com/pulumi/pulumi/sdk/v3/go/pulumi"
    "github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
    
    "github.com/james/monorepo/pulumi_dev_local/pkg/resources"
)

func DeployRedis(ctx *pulumi.Context, provider *kubernetes.Provider) (pulumi.Resource, error) {
    // Get configuration
    cfg := config.New(ctx, "dev-local-infrastructure")
    
    redisEnabled := cfg.GetBoolWithDefault("redis_enabled", false)
    if !redisEnabled {
        ctx.Log.Info("Redis is disabled, skipping deployment", nil)
        return nil, nil
    }
    
    redisPassword := cfg.Get("redis_password")
    if redisPassword == "" {
        redisPassword = "redis-password"
    }
    
    // Create Redis chart resource
    redisChart, err := helm.NewRelease(ctx, "redis", &helm.ReleaseArgs{
        Chart:   pulumi.String("redis"),
        Version: pulumi.String("18.19.1"),
        RepositoryOpts: &helm.RepositoryOptsArgs{
            Repo: pulumi.String("https://charts.bitnami.com/bitnami"),
        },
        Namespace:       pulumi.String("redis"),
        CreateNamespace: pulumi.Bool(true),
        Values: pulumi.Map{
            "global": pulumi.Map{
                "imageRegistry":    pulumi.String(""),
                "imagePullSecrets": pulumi.Array{},
                "storageClass":     pulumi.String(""),
            },
            "auth": pulumi.Map{
                "enabled":          pulumi.Bool(true),
                "sentinel":         pulumi.Bool(false),
                "usePasswordFiles": pulumi.Bool(false),
                "password":         pulumi.String(redisPassword),
            },
            "master": pulumi.Map{
                "persistence": pulumi.Map{
                    "enabled": pulumi.Bool(true),
                    "size":    pulumi.String("8Gi"),
                },
                "service": pulumi.Map{
                    "type": pulumi.String("ClusterIP"),
                    "annotations": pulumi.Map{
                        "app.kubernetes.io/purpose": pulumi.String("multi-tenant"),
                    },
                },
            },
            "replica": pulumi.Map{
                "replicaCount": pulumi.Int(2),
                "persistence": pulumi.Map{
                    "enabled": pulumi.Bool(true),
                    "size":    pulumi.String("8Gi"),
                },
            },
        },
        Timeout: pulumi.Int(600),
        Wait:    pulumi.Bool(true),
    }, pulumi.Provider(provider))
    
    return redisChart, err
}
```

Then in your Istio implementation:

```go
// In pulumi_dev_local/pkg/applications/istio.go
// Add rate limiting integration if Redis is enabled
redisEnabled := conf.GetBool("redis_enabled", false)

if redisEnabled {
    // Create EnvoyFilter for Redis rate limiting
    _, err = resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
        Name: "rate-limit-service",
        YAML: `apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: rate-limit-service
  namespace: istio-system
spec:
  workloadSelector:
    labels:
      istio: ingressgateway
  configPatches:
  - applyTo: CLUSTER
    match:
      context: GATEWAY
    patch:
      operation: ADD
      value:
        name: rate_limit_service
        type: STRICT_DNS
        connect_timeout: 10s
        lb_policy: ROUND_ROBIN
        load_assignment:
          cluster_name: rate_limit_service
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: redis-master.redis.svc.cluster.local
                    port_value: 6379
`,
    }, pulumi.DependsOn([]pulumi.Resource{istioIngressGateway}))
    if err != nil {
        return err
    }
}
```

By following this guide, you should be able to successfully add new infrastructure components to both the Terraform and Pulumi implementations while maintaining feature parity and best practices. 