# Utility Functions and Abstractions

This document provides detailed information about the utility functions and abstractions used in the Terraform and Pulumi implementations of the infrastructure components.

## Pulumi Utilities

The Pulumi implementation uses helper functions organized into packages to provide reusable abstractions and improve code maintainability.

### Configuration Management (`pkg/utils/config.go`)

The `PulumiConfig` wrapper provides a consistent interface for accessing configuration values with default fallbacks.

```go
// Example usage in component implementation
cfg := utils.NewConfig(ctx)
redisPassword := cfg.GetString("redis_password", "redis-password")
redisEnabled := cfg.GetBool("redis_enabled", false)
```

#### Key Methods

| Method | Description | Example |
|--------|-------------|---------|
| `NewConfig(ctx)` | Creates a new configuration wrapper | `cfg := utils.NewConfig(ctx)` |
| `GetString(key, defaultValue)` | Gets a string config value with fallback | `version := cfg.GetString("redis_version", "18.19.1")` |
| `GetBool(key, defaultValue)` | Gets a boolean config value with fallback | `enabled := cfg.GetBool("istio_enabled", false)` |
| `GetInt(key, defaultValue)` | Gets an integer config value with fallback | `timeout := cfg.GetInt("timeout", 600)` |
| `GetNamespace(key, defaultValue)` | Gets a namespace with fallback | `ns := cfg.GetNamespace("redis", "redis")` |
| `RequireSecret(ctx, key)` | Gets a required secret value | `password := cfg.RequireSecret(ctx, "db_password")` |

### Helm Chart Deployment (`pkg/resources/helm.go`)

The `DeployHelmChart` function provides a standardized way to deploy Helm charts with consistent configuration.

```go
// Example usage in component implementation
return resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
    Name:            "redis",
    ChartName:       "redis",
    Version:         cfg.GetString("redis_version", "18.19.1"),
    RepositoryURL:   "https://charts.bitnami.com/bitnami",
    Namespace:       "redis",
    CreateNamespace: true,
    ValuesFile:      "redis", // Will load values/redis.yaml
    Values: map[string]interface{}{
        "auth": map[string]interface{}{
            "password": redisPassword,
        },
    },
    Wait:    true,
    Timeout: 1200,
})
```

#### `HelmChartConfig` Structure

| Field | Type | Description |
|-------|------|-------------|
| `Name` | `string` | Release name |
| `Namespace` | `string` | Namespace to deploy to |
| `ChartName` | `string` | Chart name |
| `RepositoryURL` | `string` | Chart repository URL |
| `Version` | `string` | Chart version |
| `Values` | `map[string]interface{}` | Values to override |
| `ValuesFile` | `string` | Name of values file to load |
| `CreateNamespace` | `bool` | Whether to create namespace |
| `SkipCRDs` | `bool` | Whether to skip CRD installation |
| `Timeout` | `int` | Timeout in seconds |
| `Wait` | `bool` | Whether to wait for resources |
| `CleanupCRDs` | `bool` | Whether to clean up CRDs before install |
| `CRDsToCleanup` | `[]string` | List of CRDs to clean up |
| `WebhooksToCleanup` | `[]string` | List of webhooks to clean up |
| `Replace` | `bool` | Whether to replace existing release |

### Kubernetes Manifest Creation (`pkg/resources/k8s.go`)

The `CreateK8sManifest` function provides a way to create raw Kubernetes resources from YAML.

```go
// Example usage for custom resources
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
  # ... rest of manifest
`,
})
```

### Values Loading (`pkg/utils/yaml.go`)

Functions to load and merge YAML values for Helm charts.

```go
// Example usage
fileValues, err := utils.LoadHelmValues("redis")
mergedValues := utils.MergeValues(fileValues, customValues)
```

## Terraform Patterns

While Terraform doesn't have function abstractions like Go, it uses consistent patterns for reusability.

### Module Variables Pattern

The Terraform implementation uses standard variable declarations with default values.

```hcl
variable "redis_enabled" {
  type    = bool
  default = false
}

variable "redis_password" {
  type      = string
  default   = "changeme"
  sensitive = true
}
```

### Conditional Resource Creation

```hcl
resource "helm_release" "redis" {
  count = var.redis_enabled ? 1 : 0
  # ... configuration ...
}
```

### Template Files for Values

```hcl
values = [
  templatefile(
    "${path.module}/helm_values/redis_values.yaml.tpl",
    {
      namespace = "redis"
    }
  )
]
```

### Explicit Dependencies

```hcl
depends_on = [helm_release.istio_base, helm_release.istio_cni]
```

## Comparison of Implementation Approaches

| Aspect | Terraform | Pulumi | Benefits |
|--------|-----------|--------|----------|
| Configuration | Variables with defaults | Config wrapper with getters | Pulumi's approach provides more type safety and fallback values |
| Code Reuse | Using modules | Using functions | Pulumi's approach is more flexible and allows for complex logic |
| Values Management | Template files | YAML loading and merging | Both approaches work well, with Pulumi offering more dynamic capabilities |
| Error Handling | Limited in HCL | Full Go error handling | Pulumi has more robust error handling and recovery options |

## Implementation Best Practices

When extending either implementation, consider the following best practices:

### For Pulumi

1. **Use the Configuration Wrapper**: Always use `utils.NewConfig(ctx)` to access configuration values.
2. **Separate Concerns**: Create new utility functions in appropriate packages when adding reusable functionality.
3. **Return Resources**: Make functions return the created resources so they can be used for dependency management.
4. **Handle Errors**: Properly handle and propagate errors up the call stack.
5. **Document Function Parameters**: Add comments to new function parameters and return values.

### For Terraform

1. **Consistent Variable Definitions**: Follow the same pattern for defining variables in `variables.tf`.
2. **Use Count for Conditionals**: Consistently use `count = var.<component>_enabled ? 1 : 0` for conditional resources.
3. **Template Organization**: Keep all templates in the `helm_values/` directory.
4. **Explicit Dependencies**: Always add explicit `depends_on` statements when dependencies are not implicit.
5. **Sensitive Variables**: Mark sensitive variables with `sensitive = true`. 