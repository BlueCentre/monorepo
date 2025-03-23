# Pulumi Helm Chart Management Best Practices

This document outlines best practices for managing Helm charts within Pulumi infrastructure code.

## Core Principles

1. **External YAML Values**: Keep Helm values in separate YAML files rather than embedding them in code.
   - Makes values portable between different IaC tools
   - Simplifies updates without changing Go code
   - Enables reuse across different environments

2. **Leverage Helm's Native Capabilities**: Use built-in Helm functionality instead of custom code.
   - Let Helm manage namespaces with `CreateNamespace: true`
   - Use Helm's CRD management capabilities
   - Configure CRD cleanup via Helm values (`crds.keep: false`)

3. **Minimize Custom Code**: Keep Pulumi code as minimal as possible.
   - Avoid custom cleanup scripts, pods, and other workarounds
   - Minimize dependency on specific Pulumi features
   - Ensure portability to other IaC tools if needed

4. **Standardized Approach**: Use consistent patterns across all components.
   - Standard directory structure for values files
   - Uniform deployment function signatures
   - Consistent error handling and resource naming

## Directory Structure

```
pulumi_dev_local/
├── pkg/
│   ├── applications/     # Component deployments
│   ├── resources/        # Common resource functions
│   └── utils/            # Utility functions
│       └── yaml.go       # YAML loading utility
└── values/               # Helm chart values
    ├── cert-manager.yaml
    ├── external-dns.yaml
    ├── external-secrets.yaml
    ├── istio.yaml
    └── monitoring.yaml
```

## Implementation Guidelines

### Values Management

1. **Store values in YAML files**:
   - Place all Helm values in separate YAML files in the `values/` directory
   - Name files consistently (e.g., `component-name.yaml`)
   - Group values by component or application
   - Use comments in YAML files to document configuration options

2. **Handle overrides gracefully**:
   - Load base values from files using `LoadHelmValues` function
   - Support runtime overrides for specific values using `MergeValues` function
   - Provide fallbacks if files are missing (empty map as default)

### Resource Creation

1. **Namespace Management**:
   - Let Helm create namespaces (`CreateNamespace: true`)
   - Export namespace names for reuse by other components

2. **CRD Management**:
   - Configure CRDs in values files with:
     ```yaml
     crds:
       enabled: true
       keep: false  # Ensures CRDs get removed when uninstalling
     ```
   - Use `installCRDs: false` to avoid the deprecated option
   - Let Helm handle CRD lifecycle management

3. **Component Dependencies**:
   - Use Pulumi's dependency tracking for ordering
   - Export component-specific outputs for other components to reference
   - Use `ctx.Export()` to make important values available to Pulumi stack outputs

### Error Handling

1. **Graceful Failures**:
   - Handle missing values files gracefully with clear warning messages
   - Provide useful error messages with context
   - Don't fail the entire deployment for non-critical errors

2. **Logging**:
   - Log important operations and decisions
   - Use appropriate format for log messages

## Implemented Utilities

### YAML Loading Functions

We've implemented two key utility functions in `pkg/utils/yaml.go`:

```go
// LoadHelmValues loads values from a YAML file in the values directory
func LoadHelmValues(valuesFile string) (map[string]interface{}, error) {
    // If no values file is specified, return an empty map
    if valuesFile == "" {
        return map[string]interface{}{}, nil
    }

    // Construct the path to the values file
    valuesPath := filepath.Join("values", valuesFile+".yaml")

    // Check if the file exists
    if _, err := os.Stat(valuesPath); os.IsNotExist(err) {
        fmt.Printf("Warning: Values file %s does not exist, using default values\n", valuesPath)
        return map[string]interface{}{}, nil
    }

    // Read the file
    data, err := ioutil.ReadFile(valuesPath)
    if err != nil {
        return nil, fmt.Errorf("failed to read values file %s: %w", valuesPath, err)
    }

    // Parse the YAML
    var values map[string]interface{}
    err = yaml.Unmarshal(data, &values)
    if err != nil {
        return nil, fmt.Errorf("failed to parse values file %s: %w", valuesPath, err)
    }

    return values, nil
}

// MergeValues merges two maps of values, with the override map taking precedence
func MergeValues(base, override map[string]interface{}) map[string]interface{} {
    result := make(map[string]interface{})

    // Copy base values
    for k, v := range base {
        result[k] = v
    }

    // Apply overrides
    for k, v := range override {
        // If both are maps, merge them recursively
        if baseMap, ok := result[k].(map[string]interface{}); ok {
            if overrideMap, ok := v.(map[string]interface{}); ok {
                result[k] = MergeValues(baseMap, overrideMap)
                continue
            }
        }
        // Otherwise, just override
        result[k] = v
    }

    return result
}
```

### Enhanced Helm Chart Configuration

We've enhanced the `HelmChartConfig` struct to support external YAML values:

```go
// HelmChartConfig defines the configuration for a Helm chart deployment
type HelmChartConfig struct {
    Name            string
    Namespace       string
    ChartName       string
    RepositoryURL   string
    Version         string
    Values          map[string]interface{}
    ValuesFile      string                 // Name of the values file to load (without .yaml extension)
    CreateNamespace bool
    SkipCRDs        bool
    Timeout         int  // in seconds
    Wait            bool
    CleanupCRDs       bool     // Enables CRD cleanup for charts like cert-manager
    CRDsToCleanup     []string // List of CRD patterns to clean up
    WebhooksToCleanup []string // List of webhook names to clean up
}
```

### Deployment Function

The `DeployHelmChart` function has been enhanced to load values from files:

```go
// DeployHelmChart creates a Helm chart release with given configuration
func DeployHelmChart(ctx *pulumi.Context, provider *kubernetes.Provider, config HelmChartConfig, opts ...pulumi.ResourceOption) (*helm.Release, error) {
    // Create the namespace if needed
    if config.CreateNamespace {
        _, err := CreateK8sNamespace(ctx, provider, K8sNamespaceConfig{
            Name: config.Namespace,
        })
        if err != nil {
            return nil, err
        }
    }

    // Load values from external YAML file if specified
    fileValues := map[string]interface{}{}
    var err error
    if config.ValuesFile != "" {
        fileValues, err = utils.LoadHelmValues(config.ValuesFile)
        if err != nil {
            return nil, fmt.Errorf("error loading values file for %s: %w", config.Name, err)
        }
    }

    // Merge file values with provided values (provided values take precedence)
    mergedValues := utils.MergeValues(fileValues, config.Values)

    // Rest of the function...
}
```

By following these best practices, we create maintainable Pulumi code that leverages Helm's capabilities while keeping infrastructure code portable and flexible. 
By following these best practices, we create maintainable Pulumi code that leverages Helm's capabilities while keeping infrastructure code portable and flexible. 