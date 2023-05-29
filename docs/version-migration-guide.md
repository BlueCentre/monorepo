# Component Version Migration Guide

This document provides guidance for upgrading infrastructure components to newer versions in both Terraform and Pulumi implementations.

## General Migration Process

Follow these steps when upgrading a component version:

1. **Research Changes**: Check the component's release notes for breaking changes, deprecations, or new features
2. **Update Both Implementations**: Always update both Terraform and Pulumi implementations simultaneously
3. **Test in Local Environment**: Verify upgrades locally before committing
4. **Update Documentation**: Update the component versions in both implementations' documentation

## Updating Component Versions

### In Terraform

1. Update version in `terraform.auto.tfvars`:
   ```hcl
   # From
   cert_manager_version = "1.16.0"
   
   # To
   cert_manager_version = "1.17.0"
   ```

2. If needed, update any changed Helm values in the corresponding template file:
   ```hcl
   # terraform_dev_local/helm_values/cert_manager_values.yaml.tpl
   ```

3. Apply the changes:
   ```bash
   cd terraform_dev_local
   terraform apply -auto-approve
   ```

### In Pulumi

1. Update version in `Pulumi.dev.yaml`:
   ```yaml
   # From
   dev-local-infrastructure:cert_manager_version: "1.16.0"
   
   # To
   dev-local-infrastructure:cert_manager_version: "1.17.0"
   ```

2. If needed, update any changed Helm values in the corresponding YAML file:
   ```yaml
   # pulumi_dev_local/values/cert_manager.yaml
   ```

3. Apply the changes:
   ```bash
   cd pulumi_dev_local
   pulumi up -y
   ```

## Component-Specific Migration Guides

### Istio (1.22.x → 1.23.x)

#### Breaking Changes

- Deprecated APIs have been removed in 1.23.0
- New ambient mode features added

#### Migration Steps

1. Update version numbers in both implementations as described above
2. Update EnvoyFilter configuration if using rate limiting:
   - For Terraform, check `kubernetes_manifest` resources in `helm_istio.tf`
   - For Pulumi, check `resources.CreateK8sManifest` calls in `pkg/applications/istio.go`
3. Verify gateway configurations to ensure compatibility with new APIs

#### Verification

Test service mesh functionality:
```bash
# Check Istio control plane version
kubectl get pods -n istio-system -l app=istiod -o jsonpath='{.items[0].spec.containers[0].image}'

# Check for any errors in Istio logs
kubectl logs -n istio-system -l app=istiod
```

### Cert Manager (1.16.x → 1.17.x)

#### Breaking Changes

- `cert-manager.io/v1alpha2` and `v1alpha3` APIs removed
- New certificate validation features added

#### Migration Steps

1. Update version numbers in both implementations
2. If using custom issuers or certificates, update their API versions if needed
3. Check any CertificateRequests to ensure they're using valid API versions

#### Verification

Test certificate issuance:
```bash
# Check cert-manager version
kubectl get deployments -n cert-manager cert-manager -o jsonpath='{.spec.template.spec.containers[0].image}'

# Verify no validation errors in logs
kubectl logs -n cert-manager -l app=cert-manager
```

### Redis (18.x → 19.x)

#### Breaking Changes

- Redis 7.2 introduces new features and performance improvements
- Helm chart changes in values structure

#### Migration Steps

1. Update version numbers in both implementations
2. Update values files if needed:
   - Terraform: `helm_values/redis_values.yaml.tpl`
   - Pulumi: `values/redis.yaml`
3. Ensure authentication configuration is consistent with new version

#### Verification

Test Redis connectivity:
```bash
# Check Redis version
kubectl exec -it -n redis redis-master-0 -- redis-cli info server | grep version

# Test Redis connectivity
kubectl exec -it -n redis redis-master-0 -- redis-cli -a $(kubectl get secret --namespace redis redis -o jsonpath="{.data.redis-password}" | base64 --decode) ping
```

### CloudNative PG (0.23.x → 0.24.x)

#### Breaking Changes

- New backup system introduced
- Changes to cluster resource definition

#### Migration Steps

1. Update version numbers in both implementations
2. Update CNPG cluster configurations if needed:
   - Terraform: Check CRD definitions and any custom resources
   - Pulumi: Check CreateK8sManifest calls for cluster definitions
3. Review backup configurations if using backups

#### Verification

Test PostgreSQL cluster status:
```bash
# Check operator version
kubectl get deployments -n cnpg-system cnpg-controller-manager -o jsonpath='{.spec.template.spec.containers[0].image}'

# Check cluster status
kubectl describe cluster -n cnpg-cluster
```

## Handling Failed Upgrades

If an upgrade fails, follow these recovery steps:

### Terraform Recovery

1. Rollback to the previous version in `terraform.auto.tfvars`
2. Re-apply the configuration:
   ```bash
   terraform apply -auto-approve
   ```
3. If state is corrupted:
   ```bash
   # Remove problematic resource from state
   terraform state rm helm_release.component_name
   
   # Re-apply
   terraform apply -target=helm_release.component_name
   ```

### Pulumi Recovery

1. Rollback to the previous version in `Pulumi.dev.yaml`
2. Apply the rollback:
   ```bash
   pulumi up -y
   ```
3. If state issues occur:
   ```bash
   # Refresh state
   pulumi refresh
   
   # Delete and recreate specific component
   pulumi destroy -target="*component_name*" -y
   pulumi up -target="*component_name*" -y
   ```

## Testing Strategies

When upgrading components, use these testing strategies:

1. **Use the Development Environment**: Always test upgrades in a development environment first
2. **Incremental Testing**: Test one component upgrade at a time
3. **Application Compatibility**: Test applications that depend on the upgraded component
4. **Rollback Testing**: Verify rollback procedures work as expected
5. **Documentation**: Document any issues encountered during upgrades

## Version Synchronization

To maintain version parity, use this process:

1. Create a version update PR that modifies both implementations
2. Include version change documentation in PR description
3. Update both `COMPONENTS.md` files to reflect new versions
4. Use the component feature matrix document to verify version alignment 