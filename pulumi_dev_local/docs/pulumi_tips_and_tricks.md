# Pulumi Tips and Tricks

This document collects useful tips and command-line flags to enhance your Pulumi workflow in this project.

## Always Refresh Before Update (`pulumi up --refresh`)

**Problem:** Sometimes, the actual state of resources in your cluster drifts from what Pulumi believes is deployed (stored in the state file). This can happen due to manual changes, interrupted operations, or complex resource interactions. This drift can lead to unexpected behavior or errors during `pulumi up`, especially concerning dependencies.

**Solution:** Use the `--refresh` flag with `pulumi up`.

```bash
# Perform a refresh before planning and applying changes
pulumi up --refresh

# Skip confirmation prompt
pulumi up --refresh -y
```

**How it Works:** This command forces Pulumi to first query the current state of *all* resources managed by the stack directly from Kubernetes *before* calculating the deployment plan. This ensures the plan is based on the most up-to-date information.

**Trade-off:** Using `--refresh` significantly **slows down** the `pulumi up` command, as it needs to check every resource. For routine updates where state drift is unlikely, omitting `--refresh` is faster. Use it when you suspect issues or before critical changes.

## Preview Changes with Diff (`pulumi preview --diff`)

**Tip:** Before applying any changes with `pulumi up`, always run `pulumi preview` to see what Pulumi intends to do.

To get even more detail, especially for changes within resource properties (like ConfigMaps, Secrets, or Helm values), use the `--diff` flag:

```bash
pulumi preview --diff
```

This will show the specific textual differences for resources that are planned to be updated, making it easier to spot unintended modifications.

## Target Specific Resources (`--target`)

**Tip:** If you need to update, refresh, or destroy only a specific resource or a set of resources, you can use the `--target` flag followed by the resource's URN (Uniform Resource Name).

1.  **Find the URN:** Run `pulumi stack --show-urns` to list all resources and their URNs.
2.  **Use the URN:**
    ```bash
    # Preview changes for only one specific resource
    pulumi preview --target <resource-urn>

    # Update only one specific resource
    pulumi up --target <resource-urn>

    # Destroy only one specific resource
    pulumi destroy --target <resource-urn>
    ```

**Caution:** Be careful when targeting resources, as dependencies might not be handled correctly if you only update a part of the stack.

## Show Configuration (`pulumi config`)

**Tip:** To quickly see the current configuration values set for your stack (e.g., values from `Pulumi.dev.yaml`), use:

```bash
pulumi config
```

To see a specific value:

```bash
pulumi config get <config-key>
```

## Verbose Logging for Debugging

**Tip:** When troubleshooting complex issues, use verbose logging flags (as mentioned in the troubleshooting guide):

```bash
# Increased verbosity
pulumi up -v=3

# Maximum debug logging
pulumi up -v=9 --logtostderr
```

Refer to the `pulumi_troubleshooting.md` guide for more debugging strategies. 