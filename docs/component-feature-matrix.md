# Component Feature Matrix

This document provides a comprehensive comparison of all infrastructure components available in both Terraform and Pulumi implementations.

## Component Availability and Versions

| Component | Terraform<br>Status | Pulumi<br>Status | Version<br>Terraform | Version<br>Pulumi | Namespace | Helm Repository |
|-----------|--------------|-------------|-------------------|-----------------|-----------|----------------|
| Cert Manager | ✅ Active | ✅ Active | v1.17.0 | v1.17.0 | cert-manager | https://charts.jetstack.io |
| External Secrets | ✅ Active | ✅ Active | 0.14.4 | 0.14.4 | external-secrets | https://charts.external-secrets.io |
| External DNS | ✅ Active | ✅ Active | 1.15.0 | 1.15.0 | external-dns | https://kubernetes-sigs.github.io/external-dns |
| OpenTelemetry | ✅ Active | ✅ Active | 0.79.0 | 0.79.0 | opentelemetry | https://open-telemetry.github.io/opentelemetry-helm-charts |
| Datadog | ✅ Active | ✅ Active | 3.74.1 | 3.74.1 | datadog | https://helm.datadoghq.com |
| Istio Base | ✅ Active | ✅ Active | 1.23.3 | 1.23.3 | istio-system | https://istio-release.storage.googleapis.com/charts |
| Istio CNI | ✅ Active | ✅ Active | 1.23.3 | 1.23.3 | istio-system | https://istio-release.storage.googleapis.com/charts |
| Istio Control Plane | ✅ Active | ✅ Active | 1.23.3 | 1.23.3 | istio-system | https://istio-release.storage.googleapis.com/charts |
| Istio Gateway | ✅ Active | ✅ Active | 1.23.3 | 1.23.3 | istio-system | https://istio-release.storage.googleapis.com/charts |
| Redis | ✅ Active | ✅ Active | 18.19.1 | 18.19.1 | redis | oci://registry-1.docker.io/bitnamicharts (TF)<br>https://charts.bitnami.com/bitnami (Pulumi) |
| CloudNative PG | ✅ Active | ✅ Active | 0.23.2 | 0.23.2 | cnpg-system | https://cloudnative-pg.github.io/charts |
| CloudNative PG Cluster | ✅ Active | ✅ Active | 0.2.1 | 0.2.1 | cnpg-cluster | https://cloudnative-pg.github.io/charts |
| MongoDB Operator | ✅ Active | ✅ Active | 0.12.0 | 0.12.0 | mongodb | https://mongodb.github.io/helm-charts |
| MongoDB ReplicaSet | ✅ Active | ✅ Active | 4.4.19 | 4.4.19 | mongodb | https://mongodb.github.io/helm-charts |
| ArgoCD | ✅ Active | ✅ Active | Latest | Latest | argocd | https://argoproj.github.io/argo-helm |
| Telepresence | ✅ Active | ✅ Active | Latest | Latest | telepresence | https://app.getambassador.io/charts |

## Feature Comparison by Component

### Cert Manager

| Feature | Terraform | Pulumi | Notes |
|---------|-----------|--------|-------|
| Self-signed issuer | ✅ Yes | ✅ Yes | |
| ClusterIssuer support | ✅ Yes | ✅ Yes | |
| Global leader election | ✅ Yes | ✅ Yes | Same configuration in both |
| Automatic CRD installation | ✅ Yes | ✅ Yes | |
| Pod Disruption Budget | ✅ Yes | ✅ Yes | |

### Istio Service Mesh

| Feature | Terraform | Pulumi | Notes |
|---------|-----------|--------|-------|
| Base Configuration | ✅ Yes | ✅ Yes | |
| CNI Support | ✅ Yes | ✅ Yes | |
| Control Plane (istiod) | ✅ Yes | ✅ Yes | |
| Ingress Gateway | ✅ Yes | ✅ Yes | |
| Rate Limiting (with Redis) | ✅ Yes | ✅ Yes | Same EnvoyFilter configuration |
| Dependency on Redis | ✅ Yes | ✅ Yes | When rate limiting is enabled |
| Gateway API | ✅ Yes | ✅ Yes | |

### Redis

| Feature | Terraform | Pulumi | Notes |
|---------|-----------|--------|-------|
| Authentication | ✅ Yes | ✅ Yes | Both use password from config |
| Master-Replica Setup | ✅ Yes | ✅ Yes | |
| Persistence | ✅ Yes | ✅ Yes | 8Gi for master/replicas |
| NetworkPolicy | ✅ Yes | ✅ Yes | |
| Bitnami Repo | ⚠️ Different | ⚠️ Different | Terraform: OCI URL<br>Pulumi: HTTPS URL |
| Timeout Value | ⚠️ Different | ⚠️ Different | Terraform: 600s<br>Pulumi: 1200s |

### CloudNative PG

| Feature | Terraform | Pulumi | Notes |
|---------|-----------|--------|-------|
| Operator Deployment | ✅ Yes | ✅ Yes | |
| Cluster Deployment | ✅ Yes | ✅ Yes | |
| Dependencies | ✅ Yes | ✅ Yes | Cluster depends on operator |
| Initial DB Creation | ✅ Yes | ✅ Yes | |
| Custom User/Password | ✅ Yes | ✅ Yes | |

### External Secrets

| Feature | Terraform | Pulumi | Notes |
|---------|-----------|--------|-------|
| CRD Installation | ✅ Yes | ✅ Yes | |
| Webhook Support | ✅ Yes | ✅ Yes | |
| Delay for Webhooks | ✅ Yes | ✅ Yes | To ensure readiness |
| ClusterSecretStore | ✅ Yes | ✅ Yes | |

### MongoDB

| Feature | Terraform | Pulumi | Notes |
|---------|-----------|--------|-------|
| Operator Deployment | ✅ Yes | ✅ Yes | |
| ReplicaSet Creation | ✅ Yes | ✅ Yes | |
| Authentication | ✅ Yes | ✅ Yes | |
| Persistent Storage | ✅ Yes | ✅ Yes | |

## Configuration Method Comparison

| Aspect | Terraform | Pulumi | Notes |
|--------|-----------|--------|-------|
| Configuration Definition | `variables.tf` | `Pulumi.dev.yaml` | |
| Default Values | In variable definitions | In code or config | |
| Secret Handling | Marked as sensitive | Encrypted in state | |
| Value Files | YAML templates<br>`.yaml.tpl` | Static YAML files<br>`.yaml` | Terraform uses `templatefile`<br>Pulumi uses file loading |
| Dynamic Values | Via `set` blocks | Via `Values` map | |
| Conditional Logic | `count = var.enabled ? 1 : 0` | `if enabled {...}` | |

## Dependency Management Comparison

| Aspect | Terraform | Pulumi | Notes |
|--------|-----------|--------|-------|
| Explicit Dependencies | `depends_on = [resource.name]` | `pulumi.DependsOn([resource])` | |
| Implicit Dependencies | Via reference | Via reference | |
| Wait Logic | `wait = true` | `Wait: true` | |
| Timeout Settings | `timeout = Nsec` | `Timeout: Nsec` | Inconsistent between components |

## Known Inconsistencies

1. **Redis Helm Repository URL**:
   - Terraform: `oci://registry-1.docker.io/bitnamicharts`
   - Pulumi: `https://charts.bitnami.com/bitnami`
   - **Recommendation**: Standardize on HTTPS URL per project guidelines

2. **Timeout Values**:
   - Terraform Redis: `timeout = 600`
   - Pulumi Redis: `Timeout: 1200`
   - **Recommendation**: Standardize timeout values

3. **Error Handling**:
   - Terraform: Limited error handling in HCL
   - Pulumi: More robust error handling in Go code
   - **Impact**: Pulumi implementation can potentially recover from some errors automatically

## Common Configuration Values

Below is a mapping of configuration parameters between Terraform and Pulumi for key components:

| Component | Terraform Parameter | Pulumi Parameter | Description |
|-----------|---------------------|------------------|-------------|
| General | `kubernetes_context` | `kubernetes_context` | Kubernetes context name |
| Cert Manager | `cert_manager_enabled` | `cert_manager_enabled` | Enable/disable component |
| Istio | `istio_enabled` | `istio_enabled` | Enable/disable component |
| Redis | `redis_enabled` | `redis_enabled` | Enable/disable component |
| Redis | `redis_password` | `redis_password` | Redis auth password |
| CNPG | `cnpg_enabled` | `cnpg_enabled` | Enable/disable component |
| CNPG | `cnpg_app_db_name` | `cnpg_app_db_name` | Initial database name |
| CNPG | `cnpg_app_db_user` | `cnpg_app_db_user` | Database user |
| CNPG | `cnpg_app_db_password` | `cnpg_app_db_password` | Database password | 