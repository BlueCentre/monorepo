# Infrastructure as Code Troubleshooting Guide

This document provides solutions to common issues encountered when working with the infrastructure components in this repository. It covers both Terraform and Pulumi implementations.

## Common Issues

### General Infrastructure Issues

#### Issue: Kubernetes Context Not Found

**Symptoms:**
- Error message like `context "colima" not found` or similar
- Failed initialization of Terraform or Pulumi

**Solutions:**
1. Ensure your Kubernetes cluster (Colima) is running:
   ```bash
   colima status
   # If not running
   colima start
   ```
2. Verify your Kubernetes context:
   ```bash
   kubectl config get-contexts
   kubectl config use-context colima
   ```
3. Update your Terraform/Pulumi configuration to use the correct context name:
   - Terraform: Set `kubernetes_context` in `terraform.auto.tfvars`
   - Pulumi: Set `kubernetes_context` in `Pulumi.dev.yaml`

#### Issue: Component CRDs Not Installing

**Symptoms:**
- Error messages about missing Custom Resource Definitions (CRDs)
- Components partially installed but not working

**Solutions:**
1. Manually install the CRDs:
   ```bash
   kubectl apply -f https://URL-TO-COMPONENT-CRDS
   ```
2. Check if CRDs were installed in a different namespace:
   ```bash
   kubectl get crds | grep component-name
   ```
3. Update configuration to ensure CRD installation:
   - Terraform: Set `installCRDs = true` in Helm values
   - Pulumi: Ensure `InstallCRDs: true` in the values map

## Terraform-Specific Issues

### Issue: Terraform Provider Initialization Failures

**Symptoms:**
- `terraform init` fails with provider errors
- Error about incompatible provider versions

**Solutions:**
1. Clear the Terraform cache and reinitialize:
   ```bash
   rm -rf .terraform
   terraform init
   ```
2. Check provider version compatibility in `versions.tf`
3. Update the Terraform lock file:
   ```bash
   terraform init -upgrade
   ```

### Issue: Terraform State Corruption

**Symptoms:**
- Error about state corruption
- Failed operations despite no configuration changes

**Solutions:**
1. Back up the current state:
   ```bash
   cp terraform.tfstate terraform.tfstate.backup
   ```
2. If using remote state, try refreshing:
   ```bash
   terraform refresh
   ```
3. For serious corruption, consider using state recovery tools or importing resources again

### Issue: Terraform Resource Dependencies

**Symptoms:**
- Resources created in the wrong order
- Error about resources not found or not ready

**Solutions:**
1. Add explicit `depends_on` statements:
   ```hcl
   resource "helm_release" "example" {
     # resource configuration
     depends_on = [helm_release.required_dependency]
   }
   ```
2. Add explicit `wait = true` and appropriate timeouts to Helm releases

## Pulumi-Specific Issues

### Issue: Pulumi Stack Reference Errors

**Symptoms:**
- Error about missing stack or stack reference
- Unable to deploy resources that depend on stack outputs

**Solutions:**
1. Ensure the stack exists:
   ```bash
   pulumi stack ls
   ```
2. Select the correct stack:
   ```bash
   pulumi stack select dev
   ```
3. If using stack references, make sure the referenced stack has been deployed

### Issue: Pulumi State Lock Conflicts

**Symptoms:**
- Error message about state being locked
- Unable to run Pulumi operations even after previous operations completed

**Solutions:**
1. Force unlock the stack:
   ```bash
   pulumi cancel
   ```
2. If the above doesn't work, check if there are any running Pulumi operations in other terminals
3. As a last resort, manually unlock the state:
   ```bash
   pulumi stack --show-secrets | grep lock
   # Follow instructions for your specific backend to unlock
   ```

### Issue: Pulumi Resource Registration Errors

**Symptoms:**
- Error about resource registration
- Components deploy but with incorrect configurations

**Solutions:**
1. Check the component definition:
   ```go
   // Make sure resource registrations use consistent naming
   // For example, in pkg/applications/component.go:
   resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
     Name: "consistent-resource-name",
     // ...
   })
   ```
2. Try running with preview first:
   ```bash
   pulumi preview
   ```
3. Use `pulumi refresh` to reconcile state with actual infrastructure

## Component-Specific Issues

### Cert Manager

#### Issue: Certificate Issuance Failures

**Symptoms:**
- Certificates stay in 'Pending' state
- Error logs in cert-manager pods

**Solutions:**
1. Check the self-signed issuer is created:
   ```bash
   kubectl get clusterissuer -n cert-manager
   ```
2. Check cert-manager logs:
   ```bash
   kubectl logs -n cert-manager -l app=cert-manager
   ```
3. Verify DNS settings for ACME-based issuers

### Istio

#### Issue: Sidecar Injection Not Working

**Symptoms:**
- Pods not showing Istio sidecar container
- Services not appearing in Istio dashboard

**Solutions:**
1. Verify namespace has the correct injection label:
   ```bash
   kubectl get namespace your-namespace --show-labels
   kubectl label namespace your-namespace istio-injection=enabled
   ```
2. Check Istio control plane is healthy:
   ```bash
   kubectl get pods -n istio-system
   ```
3. Restart problematic pods after adding the injection label:
   ```bash
   kubectl rollout restart deployment -n your-namespace
   ```

#### Issue: Istio EnvoyFilter Not Applied

**Symptoms:**
- Rate limiting or other EnvoyFilter functionality not working
- No errors but behavior not changing

**Solutions:**
1. Verify the EnvoyFilter is installed:
   ```bash
   kubectl get envoyfilter -n istio-system
   ```
2. Check the target selector matches your gateway:
   ```bash
   kubectl describe envoyfilter -n istio-system
   ```
3. Restart the Istio ingress gateway:
   ```bash
   kubectl rollout restart deployment/istio-ingressgateway -n istio-system
   ```

### Redis

#### Issue: Redis Authentication Failures

**Symptoms:**
- Applications cannot connect to Redis
- Error logs showing authentication failures

**Solutions:**
1. Verify the Redis password is correctly set:
   - Terraform: Check `redis_password` in `terraform.auto.tfvars`
   - Pulumi: Check `redis_password` in `Pulumi.dev.yaml`
2. Check Redis pod is running:
   ```bash
   kubectl get pods -n redis
   ```
3. Test connection with Redis CLI:
   ```bash
   kubectl exec -it redis-master-0 -n redis -- redis-cli -a $(kubectl get secret --namespace redis redis -o jsonpath="{.data.redis-password}" | base64 --decode)
   ```

## Cloud Native PG

#### Issue: Database Not Initializing

**Symptoms:**
- Postgres cluster pods in pending or error state
- Applications cannot connect to PostgreSQL

**Solutions:**
1. Check CNPG operator logs:
   ```bash
   kubectl logs -n cnpg-system -l app.kubernetes.io/name=cloudnative-pg
   ```
2. Verify PVC is provisioned correctly:
   ```bash
   kubectl get pvc -n cnpg-cluster
   ```
3. Check CNPG cluster events:
   ```bash
   kubectl describe cluster -n cnpg-cluster
   ```

## Performing Recovery

### Full Infrastructure Redeployment

If multiple components are failing or in inconsistent states, sometimes it's easiest to redeploy everything:

**Terraform:**
```bash
cd terraform_dev_local
terraform destroy -auto-approve
terraform apply -auto-approve
```

**Pulumi:**
```bash
cd pulumi_dev_local
pulumi destroy -y
pulumi up -y
```

### Component-Only Redeployment

To redeploy only a specific component:

**Terraform:**
1. Remove the component from state:
   ```bash
   terraform state rm helm_release.component_name
   ```
2. Apply again:
   ```bash
   terraform apply -target=helm_release.component_name
   ```

**Pulumi:**
1. Use the refresh command first:
   ```bash
   pulumi refresh -y
   ```
2. Update specific resources:
   ```bash
   pulumi up --target="*component_name*" -y
   ```

## Getting Help

If you encounter issues not covered in this guide:

1. Check the component's official documentation
2. Look for relevant errors in Kubernetes logs:
   ```bash
   kubectl logs -n component-namespace -l app=component-name
   ```
3. Check events for potential issues:
   ```bash
   kubectl get events -n component-namespace --sort-by='.lastTimestamp'
   ```
4. Raise an issue on the repository with detailed information about your problem and logs 