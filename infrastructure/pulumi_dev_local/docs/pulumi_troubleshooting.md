# Pulumi Troubleshooting Guide

This guide covers common issues encountered when working with Pulumi in this project and how to resolve them.

## Dependency Issues / Incorrect Deployment Order

**Symptom:** Resources seem to deploy in an unexpected order, or a deployment fails because a dependency (like a CRD or webhook from another Helm chart) isn't ready, even though `DependsOn` is specified in the code.

**Cause:** The Pulumi state file might be out of sync with the actual state of resources in the Kubernetes cluster. Pulumi relies on its state file to understand dependencies and track resource creation.

**Solution:** Run `pulumi refresh` before `pulumi up` to force Pulumi to reconcile its state with the cluster.

```bash
pulumi refresh -y
pulumi up -y
```

This command checks the status of deployed resources and updates the state file accordingly, often resolving issues related to deployment order or perceived missing dependencies.

## Helm Chart Deployment Timeouts or Failures

**Symptom:** A Helm chart deployed via `resources.DeployHelmChart` fails to deploy, potentially timing out or showing errors related to readiness checks.

**Cause:**
*   **Underlying Pod Issues:** The pods managed by the Helm chart might be failing to start or become ready due to configuration errors, resource limits, persistent volume issues, or problems connecting to other services.
*   **Webhook Readiness:** Some charts (like cert-manager or Istio) rely on admission webhooks. The Helm release might finish deploying manifests before the webhook pods are fully operational, causing subsequent resources that depend on those webhooks to fail. The `Wait: true` flag in `DeployHelmChart` helps, but complex dependencies might still cause issues.
*   **Network Issues:** Network policies or other connectivity problems might prevent pods from communicating or pulling necessary images.

**Solution:**
1.  **Check Pod Status & Logs:** Identify the namespace the chart is deployed into (check `Pulumi.dev.yaml` or the component's code) and investigate the pods:
    ```bash
    kubectl get pods -n <namespace> -w
    kubectl describe pod <failing-pod-name> -n <namespace>
    kubectl logs <failing-pod-name> -n <namespace>
    # Check previous container logs if it restarted
    kubectl logs <failing-pod-name> -n <namespace> -p
    ```
2.  **Increase Timeout:** If it's a large chart or slow cluster, consider increasing the `Timeout` parameter in the `HelmChartConfig`.
3.  **Review Values:** Double-check the Helm values being passed (both from `values/{component}.yaml` and dynamic overrides in the Go code) for correctness.

## Debugging Pulumi Execution

**Symptom:** You need more insight into what Pulumi is doing during `up`, `preview`, or `refresh`.

**Solution:** Use verbose logging flags.
*   **Basic Verbosity:** `pulumi up -v=3` (shows more detailed steps)
*   **High Verbosity:** `pulumi up -v=9 --logtostderr` (provides extensive debug logs, including API calls)

Analyze the verbose output to see the exact sequence of operations, API requests sent to Kubernetes, and any errors encountered internally by Pulumi.

## Configuration Issues

**Symptom:** A component behaves unexpectedly or fails due to incorrect configuration.

**Cause:** Configuration values might be incorrect, missing, or not properly passed to the resource.

**Solution:**
1.  **Check `Pulumi.dev.yaml`:** Verify the configuration values set for the stack.
2.  **Check Component Code:** Ensure the code using `utils.NewConfig(ctx)` is retrieving the correct configuration keys and providing sensible defaults if necessary.
3.  **Check `values/{component}.yaml`:** Verify the static Helm values in the corresponding YAML file.
4.  **Use `pulumi config`:** Check the effective configuration for the stack:
    ```bash
    pulumi config
    ```

## Authentication or Provider Errors

**Symptom:** Pulumi fails early with errors related to Kubernetes context, authentication, or provider initialization.

**Cause:**
*   Incorrect `kubernetes_context` specified in `Pulumi.dev.yaml`.
*   Local `kubeconfig` file is misconfigured or doesn't have credentials for the target context.
*   Network issues preventing connection to the Kubernetes API server.

**Solution:**
1.  **Verify Kubernetes Context:** Ensure the context name in `Pulumi.dev.yaml` matches a valid context in your `~/.kube/config`.
2.  **Test `kubectl`:** Confirm you can connect to the cluster using `kubectl` with the specified context:
    ```bash
    kubectl config use-context <your-context-name>
    kubectl get ns
    ```
3.  **Check Provider Configuration:** Review the Kubernetes provider setup in `main.go`.

Remember to consult the specific component's documentation (e.g., `docs/resources_package.md`) and the Pulumi Kubernetes provider documentation for more detailed information. 