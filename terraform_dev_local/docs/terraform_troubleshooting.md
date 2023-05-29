# Terraform Troubleshooting Guide

This guide covers common issues encountered when working with Terraform in this project and how to resolve them.

## State Drift / Incorrect Plan

**Symptom:** `terraform plan` or `terraform apply` shows unexpected changes or errors, suggesting Terraform's state file doesn't match the actual infrastructure.

**Cause:** The Terraform state file (`terraform.tfstate`) is out of sync with the actual state of resources in the Kubernetes cluster. This can happen due to manual changes made outside Terraform, interrupted apply operations, or issues with resource tracking.

**Solution:** Run `terraform refresh` before planning or applying.

```bash
# Refresh the state file to match the real infrastructure
terraform refresh

# Then proceed with planning or applying
terraform plan
terraform apply -auto-approve
```

Alternatively, you can force a refresh during the apply step, though refreshing separately first is often clearer:

```bash
terraform apply -refresh=true -auto-approve
```

**Note:** Refreshing queries the provider for every resource in the state, which can take time for large configurations.

## Helm Release Failures

**Symptom:** A `helm_release` resource fails during `terraform apply`, possibly timing out or showing errors related to chart installation or readiness.

**Cause:**
*   **Underlying Pod Issues:** Pods managed by the Helm chart are failing (CrashLoopBackOff, Pending, ImagePullBackOff). This could be due to incorrect Helm values, insufficient cluster resources, RBAC issues, PersistentVolume problems, etc.
*   **Chart Dependencies:** The chart depends on other resources (like CRDs or services from another release) that aren't ready yet.
*   **Helm/Tiller Issues (Less common with Helm 3+):** Problems with Helm itself or its communication with the Kubernetes API.
*   **Network Issues:** Cluster networking or NetworkPolicies might be blocking necessary communication for the chart's components.

**Solution:**
1.  **Check Pod Status & Logs:** Identify the namespace the Helm release is deployed into (check your `.tf` files or `variables.tf`) and investigate the pods associated with the failing release:
    ```bash
    kubectl get pods -n <namespace> -w
    kubectl describe pod <failing-pod-name> -n <namespace>
    kubectl logs <failing-pod-name> -n <namespace>
    # Check previous container logs if it restarted
    kubectl logs <failing-pod-name> -n <namespace> -p
    ```
2.  **Review Helm Values:** Carefully check the `values` provided in the `helm_release` resource block and any referenced YAML value files. Ensure they are correctly formatted and appropriate for the chart version.
3.  **Check CRD Installation:** If the chart uses CRDs, ensure they were created successfully (often by a separate `kubernetes_manifest` or `kubectl_manifest` resource, or sometimes bundled in the chart itself if `create_namespace=true` implies CRD installation hooks).
4.  **Increase Timeout:** The `helm_release` resource has a `timeout` argument (in seconds). If it's a complex chart or a slow cluster, try increasing this value.
5.  **Manual Helm Check:** Try installing/debugging the chart manually using the `helm` CLI with the same values to isolate the issue from Terraform:
    ```bash
    helm template <release-name> <chart-name> --repo <repo-url> --version <chart-version> -n <namespace> -f values.yaml --set key=value > rendered.yaml
    # Inspect rendered.yaml
    helm install <release-name> <chart-name> --repo <repo-url> --version <chart-version> -n <namespace> -f values.yaml --set key=value --debug --dry-run
    ```

## Provider Authentication/Initialization Errors

**Symptom:** Errors during `terraform init` or at the start of `plan`/`apply` related to connecting to Kubernetes or initializing the Helm/Kubernetes providers.

**Cause:**
*   **Missing or Incorrect `kubeconfig`:** Terraform cannot find a valid Kubernetes configuration file or the specified context is incorrect/missing.
*   **Authentication Issues:** Credentials in the `kubeconfig` are invalid or expired.
*   **Network Connectivity:** Terraform cannot reach the Kubernetes API server specified in the `kubeconfig`.
*   **Provider Configuration:** Errors in the `provider "kubernetes"` or `provider "helm"` blocks in your `.tf` files.

**Solution:**
1.  **Verify `kubeconfig`:** Ensure your `KUBECONFIG` environment variable is set correctly, or that `~/.kube/config` exists and is valid. Check that the context Terraform is configured to use (often via provider configuration block or environment variables) exists within the file.
2.  **Test `kubectl`:** Confirm you can connect to the cluster using `kubectl` with the same context Terraform is trying to use:
    ```bash
    kubectl config use-context <your-context-name>
    kubectl get ns
    ```
3.  **Check Provider Blocks:** Review the `provider` blocks in your Terraform configuration (`main.tf`, `providers.tf`, etc.) for any hardcoded paths or incorrect settings.
4.  **Run `terraform init`:** Ensure you run `terraform init` successfully after any provider configuration changes. Use `terraform init -reconfigure` if you suspect issues with the existing provider setup.

## Configuration Errors (`terraform validate`)

**Symptom:** Errors during `terraform plan` related to syntax, unknown variables, incorrect types, or other HCL issues.

**Solution:** Run `terraform validate`.

```bash
terraform validate
```

This command checks the syntax and internal consistency of your Terraform configuration files without accessing remote services or state. Address any errors reported by `validate` before running `plan` or `apply`.

## Debugging Terraform Execution (`TF_LOG`)

**Symptom:** You need detailed insight into Terraform's operations, provider interactions, or API calls.

**Solution:** Use the `TF_LOG` environment variable.

```bash
# Enable debug logging for the next command
export TF_LOG=DEBUG
terraform apply

# Unset the variable afterwards
export TF_LOG=

# Or set it just for one command
TF_LOG=DEBUG terraform plan
```

Common `TF_LOG` levels include `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`. `DEBUG` is usually sufficient for troubleshooting provider interactions.

Refer to the `terraform_tips_and_tricks.md` guide for more workflow tips. 