# Pulumi Utilities Documentation

This document provides an overview of utility functions implemented in the `github.com/james/monorepo/pulumi_dev_local/pkg/utils` package to ensure consistent implementations when adding new components to our Pulumi infrastructure.

## Table of Contents

- [Configuration Utilities](#configuration-utilities)
  - [Overview](#config-overview)
  - [Available Methods](#config-methods)
  - [Benefits](#config-benefits)
  - [Usage Examples](#config-examples)
- [YAML Utilities](#yaml-utilities)
  - [Overview](#yaml-overview)
  - [Available Methods](#yaml-methods)
  - [Benefits](#yaml-benefits)
  - [Usage Examples](#yaml-examples)

## Configuration Utilities <a name="configuration-utilities"></a>

### Overview <a name="config-overview"></a>

The `config.go` module provides a wrapper around Pulumi's native configuration system that adds convenience methods for retrieving configuration values with proper type conversion and default values handling.

### Available Methods <a name="config-methods"></a>

| Method | Description | Direct Implementation |
|--------|-------------|----------------------|
| `NewConfig(ctx *pulumi.Context)` | Creates a new configuration wrapper | `config.New(ctx, "")` |
| `GetNamespace(key string, defaultValue string)` | Gets a namespace from configuration with a default fallback | `ns := cfg.Get(key + ":namespace"); if ns == "" { ns = defaultValue }` |
| `GetString(key string, defaultValue string)` | Gets a string value with a default fallback | `val := cfg.Get(key); if val == "" { val = defaultValue }` |
| `GetBool(key string, defaultValue bool)` | Gets a boolean value with a default fallback | Complex multi-line implementation with error handling |
| `GetInt(key string, defaultValue int)` | Gets an integer value with a default fallback | Complex multi-line implementation with error handling |

### Benefits <a name="config-benefits"></a>

Using the configuration utilities instead of direct Pulumi configuration calls provides several advantages:

1. **Consistent Error Handling**: Default values are applied consistently when configuration values are missing or invalid.
2. **Type Safety**: Automatic type conversion with proper error handling.
3. **Code Reduction**: Less boilerplate code for checking if values exist and setting defaults.
4. **Centralized Configuration**: Common configuration patterns are implemented once and reused.
5. **Readability**: More readable code with declarative intent (e.g., `GetString("key", "default")` vs. conditional blocks).

### Usage Examples <a name="config-examples"></a>

**Without Utilities:**
```go
cfg := config.New(ctx, "")
redisPassword := cfg.Get("redis_password")
if redisPassword == "" {
    redisPassword = "REPLACE_WITH_REDIS_PASSWORD"
}
```

**With Utilities:**
```go
cfg := utils.NewConfig(ctx)
redisPassword := cfg.GetString("redis_password", "REPLACE_WITH_REDIS_PASSWORD")
```

## YAML Utilities <a name="yaml-utilities"></a>

### Overview <a name="yaml-overview"></a>

The `yaml.go` module provides utilities for loading and merging YAML configuration files, which is particularly useful for Helm chart values.

### Available Methods <a name="yaml-methods"></a>

| Method | Description | Direct Implementation |
|--------|-------------|----------------------|
| `LoadHelmValues(valuesFile string)` | Loads values from a YAML file in the values directory | Multi-step process with file checking, reading, and parsing |
| `MergeValues(base, override map[string]interface{})` | Merges two maps of values, with override taking precedence | Complex recursive implementation |

### Benefits <a name="yaml-benefits"></a>

Using the YAML utilities instead of direct file operations provides several advantages:

1. **Error Handling**: Consistent error handling for file operations and YAML parsing.
2. **Path Resolution**: Automatic resolution of file paths relative to the values directory.
3. **Graceful Fallbacks**: Returns empty maps instead of errors when files don't exist.
4. **Deep Merging**: Proper recursive merging of nested configuration structures.
5. **Standardization**: Consistent approach to loading and merging configuration across components.

### Usage Examples <a name="yaml-examples"></a>

**Without Utilities:**
```go
// Loading values
valuesPath := filepath.Join("values", "redis.yaml")
if _, err := os.Stat(valuesPath); os.IsNotExist(err) {
    fmt.Printf("Warning: Values file %s does not exist, using default values\n", valuesPath)
    values = map[string]interface{}{}
} else {
    data, err := ioutil.ReadFile(valuesPath)
    if err != nil {
        return nil, fmt.Errorf("failed to read values file: %w", err)
    }
    err = yaml.Unmarshal(data, &values)
    if err != nil {
        return nil, fmt.Errorf("failed to parse values file: %w", err)
    }
}

// Merging values (simplified, not handling nested maps)
result := make(map[string]interface{})
for k, v := range baseValues {
    result[k] = v
}
for k, v := range overrideValues {
    result[k] = v
}
```

**With Utilities:**
```go
// Loading values
values, err := utils.LoadHelmValues("redis")
if err != nil {
    return nil, fmt.Errorf("failed to load Helm values: %w", err)
}

// Merging values
mergedValues := utils.MergeValues(baseValues, overrideValues)
```

## Best Practices

1. **Always use utility functions** over direct implementations to ensure consistency.
2. **Use default values** that align with our project standards.
3. **Add new utility functions** when you find yourself repeating similar patterns across multiple components.
4. **Document new utilities** by updating this document when adding new functionality.
5. **Consider versioning** for significant changes to utility behavior.

## Contributing

When adding new utility functions:

1. Place them in the appropriate file in the `pkg/utils` directory based on functionality.
2. Add proper documentation comments to the function.
3. Update this document with the new function and usage examples.
4. Consider adding unit tests for complex utility functions. 