# Configuration Mapping Guide

This guide provides a detailed mapping between Terraform and Pulumi configuration parameters for all components in the infrastructure. Use this as a reference when migrating between implementations or when you need to find the equivalent configuration in the other tool.

## Configuration Structure Comparison

| Aspect | Terraform | Pulumi |
|--------|-----------|--------|
| Configuration file | `terraform.auto.tfvars` | `Pulumi.<stack>.yaml` |
| Variable declaration | `variables.tf` | `index.ts` / Go structs |
| Secret handling | `sensitive = true` | `--secret` flag |
| Default values | Defined in `variables.tf` | Defined in code |
| Output values | Defined in `outputs.tf` | Exported from code |

## Core Configuration Parameters

### Global Settings

| Description | Terraform Variable | Pulumi Configuration | Notes |
|-------------|-------------------|----------------------|-------|
| Kubernetes context | `kubernetes_context` | `kubernetes_context` | The Kubernetes context to use |
| Region | `region` | `region` | Cloud provider region |
| Environment | `environment` | `environment` | Environment name (dev, prod, etc.) |

### Component Enablement

| Component | Terraform Variable | Pulumi Configuration | Notes |
|-----------|-------------------|----------------------|-------|
| Cert Manager | `cert_manager_enabled` | `cert_manager_enabled` | Boolean to enable/disable |
| Istio | `istio_enabled` | `istio_enabled` | Boolean to enable/disable |
| Redis | `redis_enabled` | `redis_enabled` | Boolean to enable/disable |
| CloudNative PG | `cnpg_enabled` | `cnpg_enabled` | Boolean to enable/disable |
| External Secrets | `external_secrets_enabled` | `external_secrets_enabled` | Boolean to enable/disable |
| MongoDB | `mongodb_enabled` | `mongodb_enabled` | Boolean to enable/disable |
| OpenTelemetry | `opentelemetry_enabled` | `opentelemetry_enabled` | Boolean to enable/disable |

## Component-Specific Configuration

### Cert Manager

| Description | Terraform Variable | Pulumi Configuration | Notes |
|-------------|-------------------|----------------------|-------|
| Version | `cert_manager_version` | `cert_manager_version` | Helm chart version |
| Namespace | `cert_manager_namespace` | `cert_manager_namespace` | Kubernetes namespace |
| CRDs install method | `cert_manager_install_crds` | `cert_manager_install_crds` | Boolean for CRD installation |
| Replicas | `cert_manager_controller_replicas` | `cert_manager.controller.replicas` | In Terraform, direct variable; in Pulumi, via values file |
| Log level | `cert_manager_log_level` | `cert_manager.logLevel` | In Terraform, direct variable; in Pulumi, via values file |
| Self-signed CA | `cert_manager_self_signed_ca_enabled` | `cert_manager_self_signed_ca_enabled` | Boolean to enable default CA |

### Istio

| Description | Terraform Variable | Pulumi Configuration | Notes |
|-------------|-------------------|----------------------|-------|
| Version | `istio_version` | `istio_version` | Helm chart version |
| Namespace | `istio_namespace` | `istio_namespace` | Default: `istio-system` |
| Profile | `istio_profile` | `istio_profile` | Installation profile (default, demo, minimal) |
| Ingress Gateway Enabled | `istio_ingress_gateway_enabled` | `istio_ingress_gateway_enabled` | Boolean |
| Egress Gateway Enabled | `istio_egress_gateway_enabled` | `istio_egress_gateway_enabled` | Boolean |
| Ingress Gateway Type | `istio_ingress_gateway_service_type` | `istio.ingressGateway.service.type` | Service type (LoadBalancer, NodePort) |
| Auto Injection | `istio_auto_injection_namespaces` | `istio_auto_injection_namespaces` | List of namespaces |
| MTLS Mode | `istio_mtls_mode` | `istio_mtls_mode` | MTLS policy (STRICT, PERMISSIVE) |

### Redis

| Description | Terraform Variable | Pulumi Configuration | Notes |
|-------------|-------------------|----------------------|-------|
| Version | `redis_version` | `redis_version` | Helm chart version |
| Namespace | `redis_namespace` | `redis_namespace` | Default: `redis` |
| Architecture | `redis_architecture` | `redis_architecture` | Standalone vs Replication |
| Password | `redis_password` | `redis_password` | Must be set as secret in Pulumi |
| Persistence | `redis_persistence_enabled` | `redis.master.persistence.enabled` | Boolean for persistence |
| Storage Size | `redis_storage_size` | `redis.master.persistence.size` | Storage size (e.g. "8Gi") |
| Resource Limits | `redis_resources_limits_*` | `redis.master.resources.limits` | CPU/Memory limits |
| Metrics Enabled | `redis_metrics_enabled` | `redis.metrics.enabled` | Boolean for Prometheus metrics |

### CloudNative PG

| Description | Terraform Variable | Pulumi Configuration | Notes |
|-------------|-------------------|----------------------|-------|
| Version | `cnpg_version` | `cnpg_version` | Helm chart version |
| Namespace | `cnpg_namespace` | `cnpg_namespace` | Default: `cnpg-system` |
| Default DB Password | `cnpg_app_db_password` | `cnpg_app_db_password` | Application DB password |
| Cluster Instances | `cnpg_cluster_instances` | `cnpg_cluster_instances` | Number of PostgreSQL instances |
| Storage Size | `cnpg_storage_size` | `cnpg_storage_size` | PVC size (e.g. "10Gi") |
| PostgreSQL Version | `cnpg_postgresql_version` | `cnpg_postgresql_version` | PostgreSQL version number |
| Backup Schedule | `cnpg_backup_schedule` | `cnpg_backup_schedule` | Cron expression for backups |
| Backup Retention | `cnpg_backup_retention_policy` | `cnpg_backup_retention_policy` | Retention period |

### External Secrets

| Description | Terraform Variable | Pulumi Configuration | Notes |
|-------------|-------------------|----------------------|-------|
| Version | `external_secrets_version` | `external_secrets_version` | Helm chart version |
| Namespace | `external_secrets_namespace` | `external_secrets_namespace` | Default: `external-secrets` |
| Service Account | `external_secrets_service_account` | `external_secrets_service_account` | Service account name |
| Webhook Enabled | `external_secrets_webhook_enabled` | `external_secrets.webhook.enabled` | Boolean for webhook validation |

### MongoDB

| Description | Terraform Variable | Pulumi Configuration | Notes |
|-------------|-------------------|----------------------|-------|
| Version | `mongodb_version` | `mongodb_version` | Helm chart version |
| Namespace | `mongodb_namespace` | `mongodb_namespace` | Default: `mongodb` |
| Architecture | `mongodb_architecture` | `mongodb_architecture` | Standalone, ReplicaSet, etc. |
| Root Password | `mongodb_root_password` | `mongodb_root_password` | Must be set as secret in Pulumi |
| Authentication DB | `mongodb_auth_database` | `mongodb.auth.database` | Authentication database name |
| Persistence | `mongodb_persistence_enabled` | `mongodb.persistence.enabled` | Boolean for persistence |
| Storage Size | `mongodb_storage_size` | `mongodb.persistence.size` | Storage size (e.g. "8Gi") |

## Configuration Method Examples

### Setting Configuration in Terraform

```hcl
# terraform.auto.tfvars

kubernetes_context = "colima"
region = "us-central1"
environment = "dev"

# Component enablement
istio_enabled = true
cert_manager_enabled = true
redis_enabled = true
cnpg_enabled = true
external_secrets_enabled = true

# Istio configuration
istio_version = "1.17.2"
istio_profile = "demo"
istio_ingress_gateway_enabled = true
istio_egress_gateway_enabled = false
istio_auto_injection_namespaces = ["default", "myapp"]

# Redis configuration
redis_version = "17.11.6"
redis_architecture = "standalone"
redis_password = "secure-password"
redis_persistence_enabled = true
redis_storage_size = "8Gi"
```

### Setting Configuration in Pulumi

```bash
# Command line configuration
pulumi config set kubernetes_context colima
pulumi config set region us-central1
pulumi config set environment dev

# Component enablement
pulumi config set istio_enabled true
pulumi config set cert_manager_enabled true
pulumi config set redis_enabled true
pulumi config set cnpg_enabled true
pulumi config set external_secrets_enabled true

# Istio configuration
pulumi config set istio_version 1.17.2
pulumi config set istio_profile demo
pulumi config set istio_ingress_gateway_enabled true
pulumi config set istio_egress_gateway_enabled false
pulumi config set istio_auto_injection_namespaces '["default", "myapp"]'

# Redis configuration
pulumi config set redis_version 17.11.6
pulumi config set redis_architecture standalone
pulumi config set redis_password secure-password --secret
pulumi config set redis_persistence_enabled true
pulumi config set redis_storage_size 8Gi
```

## Values Files Mapping

Both Terraform and Pulumi use values files to customize Helm charts, but they handle them differently:

### Terraform Values Files

Located in `terraform_dev_local/templates/`:
- `cert-manager-values.yaml.tpl`
- `istio-values.yaml.tpl`
- `redis-values.yaml.tpl`
- `cnpg-values.yaml.tpl`
- `external-secrets-values.yaml.tpl`

Example of a Terraform template file with variable interpolation:

```yaml
# templates/redis-values.yaml.tpl
architecture: ${architecture}
auth:
  password: ${password}
master:
  persistence:
    enabled: ${persistence_enabled}
    size: ${storage_size}
  resources:
    limits:
      cpu: ${resources_limits_cpu}
      memory: ${resources_limits_memory}
metrics:
  enabled: ${metrics_enabled}
```

### Pulumi Values Files

Located in `pulumi_dev_local/values/`:
- `cert-manager-values.yaml`
- `istio-values.yaml`
- `redis-values.yaml`
- `cnpg-values.yaml`
- `external-secrets-values.yaml`

Pulumi values files are loaded and merged programmatically:

```go
// Example of loading values in Pulumi
valueFiles := []string{
    filepath.Join("values", "redis-values.yaml"),
    filepath.Join("values", "redis-values-override.yaml"),
}
values, err := utils.LoadYamlValues(valueFiles...)
if err != nil {
    return err
}

// Override specific values from config
if config.GetBool("redis_persistence_enabled") {
    values["master"].(map[string]interface{})["persistence"].(map[string]interface{})["enabled"] = true
}
```

## Best Practices for Configuration Mapping

1. **Maintain Consistency**: Keep variable names consistent between Terraform and Pulumi implementations
2. **Document Mapping**: Update this guide when adding new configuration parameters
3. **Use Defaults Wisely**: Set sensible defaults in both implementations
4. **Handle Secrets Properly**: Mark sensitive values as secrets in both implementations
5. **Create Abstractions**: Use helper functions or modules to abstract complex configurations
6. **Test Configuration Changes**: Verify that configuration changes work in both implementations
7. **Version Control**: Keep configuration files in version control, but exclude files with secrets

## Troubleshooting Configuration Issues

### Common Issues in Terraform

1. **Undefined Variable**: Ensure all variables are defined in `variables.tf`
2. **Type Mismatch**: Check that variable types match expected values (string, number, bool, list, map)
3. **Missing Template Variable**: Ensure all template variables have corresponding Terraform variables
4. **Secret Exposure**: Verify sensitive values are marked with `sensitive = true`

### Common Issues in Pulumi

1. **Invalid YAML**: Check YAML syntax in values files
2. **Type Conversion**: Ensure proper type conversion when loading YAML values
3. **Missing Configuration**: Verify all required configuration values are set
4. **Stack Reference**: Check stack name when referencing configuration
5. **Secret Access**: Ensure secrets are accessed correctly in code 