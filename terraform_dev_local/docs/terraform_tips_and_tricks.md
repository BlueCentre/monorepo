# Terraform Tips and Tricks

This document collects useful tips and command-line flags to enhance your Terraform workflow in this project.

## Validate Configuration (`terraform validate`)

**Tip:** Before running `terraform plan` or `apply`, always check your configuration files for syntax errors and internal consistency.

```bash
terraform validate
```

This catches common HCL errors quickly without needing to contact the provider or access state.

## Format Code (`terraform fmt`)

**Tip:** Keep your Terraform HCL code consistently formatted according to Terraform's standard style.

```bash
# Format all .tf files in the current directory and subdirectories
terraform fmt -recursive
```

This improves readability and maintainability.

## Understand Proposed Changes (`terraform plan`)

**Tip:** Always run `terraform plan` before `terraform apply` to see exactly what changes Terraform intends to make to your infrastructure.

```bash
terraform plan
```

Review the plan output carefully to ensure it matches your expectations. Look for resources being created (+), updated (~), or destroyed (-).

## Save and Re-use Plans

**Tip:** For critical changes or complex environments, you can save a plan to a file and then apply that specific plan later. This guarantees that only the exact changes reviewed in the plan file are applied.

```bash
# Create a plan and save it to a file
terraform plan -out=tfplan.out

# Review tfplan.out (it's a binary file, but the original plan output showed what's in it)

# Apply the saved plan exactly
terraform apply "tfplan.out"
```

## Refresh State (`terraform refresh`)

**Problem:** Terraform's state file (`terraform.tfstate`) might not reflect the actual state of your infrastructure if changes were made outside of Terraform (e.g., manual changes via `kubectl`).

**Solution:** Explicitly refresh the state file.

```bash
terraform refresh
```

**How it Works:** This command queries the provider (Kubernetes) for the current status of all resources managed in the state file and updates the `terraform.tfstate` file to match.

**Note:** `terraform plan` and `terraform apply` often perform an implicit refresh, but running it explicitly can be useful for diagnosing state drift or before making targeted changes. You can also force a refresh during apply with `terraform apply -refresh=true`.

## Target Specific Resources (`-target`)

**Tip:** If you need to plan, apply, or destroy only a specific resource or module, use the `-target` flag.

1.  **Identify the Resource Address:** Find the address in your `.tf` files (e.g., `helm_release.redis`, `module.vpc.aws_subnet.private`).
2.  **Use the Address:**
    ```bash
    # Plan changes only for the redis helm release
    terraform plan -target=helm_release.redis

    # Apply changes only for the redis helm release
    terraform apply -target=helm_release.redis

    # Destroy only the redis helm release
    terraform destroy -target=helm_release.redis
    ```

**Caution:** Use `-target` with care. Applying changes to only part of your configuration can lead to an inconsistent state or break dependencies if not managed properly. It's primarily useful for troubleshooting or specific refactoring tasks.

## Inspect State (`terraform state`)

**Tip:** You can inspect the contents of your Terraform state file using various subcommands.

```bash
# List all resources managed in the state
terraform state list

# Show details for a specific resource in the state
terraform state show <resource-address>
# Example: terraform state show helm_release.cert_manager
```

This is useful for understanding what Terraform currently manages and troubleshooting state-related issues.

## Debug Logging (`TF_LOG`)

**Tip:** For in-depth troubleshooting, enable debug logging using the `TF_LOG` environment variable (as mentioned in the troubleshooting guide).

```bash
# Enable debug logging for the next command
export TF_LOG=DEBUG
terraform apply

# Unset the variable afterwards
export TF_LOG=

# Or set it just for one command
TF_LOG=DEBUG terraform plan
```

Refer to the `terraform_troubleshooting.md` guide for more debugging strategies. 