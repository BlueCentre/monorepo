# Helm Values Management Approach

This document explains our approach to managing Helm chart values in the Pulumi local development environment.

## Current Approach: External YAML Files

We've implemented a system where Helm chart values are stored in external YAML files located in the `values/` directory. This approach offers several benefits:

### Benefits

1. **Separation of Concerns**
   - Configuration (values) is separated from implementation (Go code)
   - Changes to configuration don't require code changes
   - Minimizes risk when updating values

2. **Improved Readability**
   - YAML files are more readable than embedding values in Go code
   - Comments can be added to explain values
   - Format is identical to what Helm expects

3. **Portability**
   - Values can be reused with other IaC tools like Terraform
   - Values can be used directly with Helm CLI if needed
   - Easier to share values across environments

4. **Consistency**
   - Standard format and location for all components
   - Predictable naming convention
   - Easier to learn and maintain

### Implementation

The implementation consists of:

1. **Values Directory**: `pulumi_dev_local/values/`
   - Contains YAML files for each component (e.g., `cert-manager.yaml`)
   - Uses standard Helm chart values format
   - Includes comments for documentation

2. **Utilities**: `pkg/utils/yaml.go`
   - `LoadHelmValues`: Loads values from a YAML file
   - `MergeValues`: Merges file values with runtime overrides

3. **Enhanced HelmChartConfig**: `pkg/resources/helm.go`
   - Added `ValuesFile` field to specify which values file to load
   - Modified deployment function to load values and merge with overrides

## Alternative Approaches

### 1. Embedded Values in Go Code

```go
values := map[string]interface{}{
    "resources": map[string]interface{}{
        "requests": map[string]interface{}{
            "cpu": "10m",
            "memory": "32Mi",
        },
    },
    "crds": map[string]interface{}{
        "enabled": true,
        "keep": false,
    },
}
```

**Drawbacks**:
- Less readable than YAML
- Hard to maintain for large configurations
- No easy way to add comments
- Requires recompilation to change values

### 2. Values in Pulumi Config

```yaml
# Pulumi.dev.yaml
config:
  cert-manager:values:
    resources:
      requests:
        cpu: 10m
        memory: 32Mi
    crds:
      enabled: true
      keep: false
```

**Drawbacks**:
- Mixes application configuration with stack configuration
- Can make stack config very large and unwieldy
- Not as portable to other IaC tools

### 3. Inline Values in YAML Components

```yaml
# components/cert-manager.yaml
resources:
  - name: cert-manager
    type: kubernetes:helm:v3:Chart
    properties:
      chart: cert-manager
      version: v1.11.0
      values:
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
        crds:
          enabled: true
          keep: false
```

**Drawbacks**:
- Mixes configuration with deployment logic
- Less reusable across different environments
- More difficult to update values independently

## Conclusion

The external YAML files approach provides the best balance of maintainability, readability, and portability. It aligns with Helm's native approach to values management while providing the flexibility needed in an infrastructure-as-code environment.

By separating values from code, we make both easier to maintain and update, reducing the risk of errors and making our infrastructure more adaptable to changing requirements. 