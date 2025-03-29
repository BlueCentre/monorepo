# Non-Interactive Pulumi Deployments

When running Pulumi in CI/CD pipelines or other automated environments, you'll often want to execute deployments (`pulumi up`) without requiring interactive confirmation prompts.

## Why `-y` Isn't Always Enough

While many CLI tools use a `-y` or `--yes` flag for non-interactive confirmation, relying solely on `pulumi up -y` might not be sufficient or the most robust approach, especially with potential complexities like:

*   Passphrase requirements for decrypting configuration.
*   Authentication needs (cloud providers, Pulumi backend).
*   Potential state file conflicts or pending operations requiring intervention.

## Recommended Non-Interactive Methods

Here are more reliable ways to achieve non-interactive deployments:

1.  **Using Environment Variables (Recommended)**:
    This is generally the preferred method for CI/CD.
    ```bash
    # Ensure the correct stack is selected
    pulumi stack select <your-stack-name>

    # Provide the passphrase for configuration decryption
    export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"

    # Tell Pulumi to skip interactive confirmations
    export PULUMI_SKIP_CONFIRMATIONS=true

    # Run the standard update command
    pulumi up
    ```
    *Ensure the passphrase is provided securely, e.g., via CI/CD secrets management.* 

2.  **Using `--skip-preview`**:
    This skips the preview phase and directly attempts the update. It still requires the passphrase if config secrets are used.
    ```bash
    export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"
    pulumi up --skip-preview
    ```
    *Use with caution, as skipping the preview means you won't see the planned changes before they are applied.* 

3.  **Using Shell Pipe (Less Recommended)**:
    Piping `yes` can sometimes work, but it's less reliable as it might answer prompts you didn't intend to confirm.
    ```bash
    export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"
    yes | pulumi up
    ```
    *This is generally discouraged in favor of `PULUMI_SKIP_CONFIRMATIONS`.* 

## Troubleshooting Non-Interactive Deployments

If your automated `pulumi up` fails:

1.  **Check for Pending Operations**:
    Sometimes a previous operation might not have completed cleanly. Try canceling it:
    ```bash
    pulumi cancel
    ```
    You might need `--force` if it's stuck:
    ```bash
    pulumi cancel --force
    ```

2.  **Ensure Correct Stack is Selected**:
    Verify the CI/CD job is operating on the intended stack:
    ```bash
    pulumi stack select <your-stack-name>
    ```

3.  **Verify Authentication and Permissions**:
    Ensure the environment has the necessary cloud provider credentials and permissions configured correctly. Check that the `PULUMI_ACCESS_TOKEN` (if using Pulumi Cloud) is valid.

4.  **Check Passphrase**: 
    Confirm the `PULUMI_CONFIG_PASSPHRASE` environment variable is correctly set and matches the stack's passphrase.

5.  **Examine Verbose Logs**:
    Run the command with increased verbosity to get more detailed error messages:
    ```bash
    pulumi up --verbose=9
    ```

6.  **State Lock Issues**: 
    Pulumi uses locking to prevent concurrent operations on the same stack. If a previous run crashed, the lock might persist. `pulumi cancel` usually resolves this. In rare cases, manual intervention in the backend (e.g., deleting a lock file in S3 if using an S3 backend) might be needed, but proceed with extreme caution.

By using the `PULUMI_SKIP_CONFIRMATIONS` environment variable and ensuring the passphrase and credentials are correctly supplied, you can achieve reliable non-interactive Pulumi deployments for your automation pipelines. 