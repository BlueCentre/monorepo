# Resources Package Documentation

This document explains the purpose, design, and benefits of the `resources` package in our Pulumi infrastructure codebase.

## Overview

The `resources` package (`github.com/james/monorepo/pulumi_dev_local/pkg/resources`) provides a set of high-level abstractions for creating and managing Kubernetes resources in a consistent, reusable manner. It serves as an abstraction layer between the raw Pulumi Kubernetes SDK and our application-specific code.

## Purpose

The resources package was created to:

1. **Standardize Resource Creation**: Provide a consistent way to create and configure common Kubernetes resources across different components.
2. **Reduce Duplication**: Centralize common patterns and boilerplate code for resource creation.
3. **Encapsulate Complexity**: Hide complex resource creation logic behind simple, declarative interfaces.
4. **Enhance Maintainability**: Make it easier to update resource creation patterns across the entire codebase.
5. **Promote Best Practices**: Enforce consistent configuration and security practices.

## Package Contents

The `resources` package includes the following key files:

### 1. `helm.go`

Provides abstractions for deploying Helm charts with consistent configurations:

- `HelmChartConfig`: A struct for configuring Helm chart deployments with all common options
- `DeployHelmChart`: A function that standardizes Helm chart deployment with proper error handling and resource cleanup
- `RunCommandResourceConfig`: Helps with custom command execution in the cluster
- Helper functions for CRD cleanup and value conversion

### 2. `kubernetes.go`

Offers general-purpose Kubernetes resource creation utilities:

- `NamespaceConfig`: Configuration for Kubernetes namespaces
- `CreateNamespace`: Creates namespaces with consistent labeling
- `ConfigMapConfig`: Configuration for Kubernetes ConfigMaps
- `CreateConfigMap`: Creates ConfigMaps with proper error handling

### 3. `namespace.go`

Specializes in namespace management:

- `K8sNamespaceConfig`: Configuration for Kubernetes namespaces
- `CreateK8sNamespace`: Creates Kubernetes namespaces with standardized metadata

### 4. `manifest.go`

Simplifies deployment of raw Kubernetes YAML manifests:

- `K8sManifestConfig`: Configuration for Kubernetes YAML manifests
- `CreateK8sManifest`: Deploys Kubernetes resources from YAML strings

## Benefits

Using the `resources` package instead of direct Pulumi Kubernetes SDK calls provides several advantages:

### 1. Consistency and Standardization

- **Uniform Resource Configuration**: All resources created through this package follow the same patterns.
- **Standardized Error Handling**: Consistent approach to handling creation errors.
- **Automatic Best Practices**: Built-in patterns for resource labeling, naming, and configuration.

### 2. Simplified Component Implementation

- **Declarative Resource Definitions**: Resources can be defined using simple configuration structs.
- **Reduced Boilerplate**: Common patterns are abstracted away, reducing the code needed in component implementations.
- **Clear Resource Dependencies**: Simplifies defining dependencies between resources.

### 3. Advanced Features

- **Automated Cleanup Logic**: Helm charts with CRDs can be cleaned up properly.
- **Value Loading and Merging**: Automatic loading and merging of values from files and runtime configurations.
- **Resource Templating**: Resources can be templated and parameterized easily.

### 4. Maintainability

- **Centralized Updates**: Changes to resource creation patterns can be made in one place.
- **Consistent Testing**: Easier to test resource creation logic in isolation.
- **Simplified Debugging**: Standardized error messages and resource creation patterns.

### 5. Security and Compliance

- **Enforced Security Practices**: Resources are created with proper security configurations.
- **Consistent RBAC**: Role-based access control can be standardized.
- **Audit Trail**: Resource creation is consistently logged and traceable.

## Usage Examples

### Deploying a Helm Chart

**Without Resources Package:**
```go
releaseArgs := &helm.ReleaseArgs{
    Chart: pulumi.String("redis"),
    Version: pulumi.String("14.4.0"),
    RepositoryOpts: &helm.RepositoryOptsArgs{
        Repo: pulumi.String("https://charts.bitnami.com/bitnami"),
    },
    Namespace: pulumi.String("redis"),
    CreateNamespace: pulumi.Bool(true),
    Values: convertValuesToMap(values),
}

release, err := helm.NewRelease(ctx, "redis", releaseArgs, pulumi.Provider(provider))
if err != nil {
    return nil, err
}
```

**With Resources Package:**
```go
release, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
    Name: "redis",
    ChartName: "redis",
    Version: "14.4.0",
    RepositoryURL: "https://charts.bitnami.com/bitnami",
    Namespace: "redis",
    CreateNamespace: true,
    ValuesFile: "redis", // Will load values/redis.yaml
})
if err != nil {
    return nil, err
}
```

### Creating a Namespace

**Without Resources Package:**
```go
ns, err := corev1.NewNamespace(ctx, "istio-system", &corev1.NamespaceArgs{
    Metadata: &metav1.ObjectMetaArgs{
        Name: pulumi.String("istio-system"),
        Labels: pulumi.StringMap{
            "istio-injection": pulumi.String("enabled"),
        },
    },
}, pulumi.Provider(provider))
if err != nil {
    return nil, err
}
```

**With Resources Package:**
```go
ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
    Name: "istio-system",
    Labels: map[string]string{
        "istio-injection": "enabled",
    },
})
if err != nil {
    return nil, err
}
```

## Best Practices

When working with the resources package:

1. **Always use the package's functions** instead of directly creating resources with the Pulumi SDK.
2. **Add new resource types** to the package when you find yourself creating similar resources across multiple components.
3. **Document new resource configurations** thoroughly with comments.
4. **Use consistent naming** for resource configs and creation functions.
5. **Consider backwards compatibility** when modifying existing resource creation functions.

## Extending the Resources Package

To add new resource types to the package:

1. Create a new file or add to an existing file based on resource category.
2. Define a configuration struct for the resource.
3. Implement a creation function that handles error checking and common patterns.
4. Document the new resource type and function with comments.
5. Update this documentation to include the new resource type.

## Conclusion

The resources package is a fundamental part of our Pulumi infrastructure codebase, providing consistent, reusable abstractions for Kubernetes resource creation. By leveraging this package, we ensure consistency across our infrastructure, reduce code duplication, and make our codebase more maintainable and robust. 