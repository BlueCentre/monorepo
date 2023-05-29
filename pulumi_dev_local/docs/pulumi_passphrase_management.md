# Managing the Pulumi Passphrase

Pulumi uses a passphrase to encrypt sensitive configuration values stored in your stack's configuration file (`Pulumi.<stack-name>.yaml`). This ensures that secrets like API keys or database passwords are not stored in plain text.

## Setting the Passphrase

The passphrase must be provided whenever Pulumi needs to access encrypted configuration values (e.g., during `pulumi up`, `pulumi preview`, `pulumi config`).

It can be set in several ways:

1.  **Environment Variable** (Recommended for development and CI/CD):
    Set the `PULUMI_CONFIG_PASSPHRASE` environment variable:
    ```bash
    export PULUMI_CONFIG_PASSPHRASE="your-secure-passphrase"
    pulumi up
    ```
    This is the most common method for non-interactive environments.

2.  **Command-Line Flag**:
    Use the `--config-passphrase` flag:
    ```bash
    pulumi up --config-passphrase="your-secure-passphrase"
    ```

3.  **Interactive Prompt**:
    If neither the environment variable nor the flag is provided, Pulumi will prompt you interactively to enter the passphrase when needed.

**Note**: If you are using the local backend (`pulumi login --local`), the passphrase is only used for stack configuration encryption. For the Pulumi Cloud backend, it's also used for state encryption.

## Changing the Passphrase

If you need to change the passphrase for an existing stack:

1.  **Export Current Stack Configuration**:
    Use the *old* passphrase to export the stack's configuration.
    ```bash
    export PULUMI_CONFIG_PASSPHRASE="<old-passphrase>"
    pulumi stack export --file stack.json
    unset PULUMI_CONFIG_PASSPHRASE
    ```

2.  **Import Stack Configuration with New Passphrase**:
    Import the configuration using the *new* passphrase.
    ```bash
    export PULUMI_CONFIG_PASSPHRASE="<new-passphrase>"
    pulumi stack import --file stack.json
    unset PULUMI_CONFIG_PASSPHRASE
    ```
    This re-encrypts the configuration with the new passphrase.

3.  **Clean up** by removing the temporary file:
    ```bash
    rm stack.json
    ```

## Best Practices for Passphrase Management

1.  **Use a Strong Passphrase**: Choose a secure, randomly generated passphrase.
2.  **Don't Commit the Passphrase**: Never store the passphrase itself in version control.
3.  **Use Different Passphrases** for different environments (dev, staging, production).
4.  **Rotate Passphrases** periodically for enhanced security if your security policy requires it.
5.  **Use a Password Manager** or secrets management system (like HashiCorp Vault, AWS Secrets Manager, etc.) to securely store and manage passphrases, especially for team environments and CI/CD.
6.  **Document the Procedure** for passphrase recovery and rotation within your team.

## Troubleshooting Passphrase Issues

If you encounter passphrase-related errors:

-   **"failed to decrypt configuration: incorrect passphrase"** (or similar): You're likely using the wrong passphrase for the stack. Verify you have the correct one.
-   **"passphrase must be set"**: You haven't provided the passphrase via the environment variable, flag, or interactive prompt when an operation required accessing encrypted configuration.
-   **Lost Passphrase**: If the passphrase for a stack is truly lost, there is no way to recover the encrypted configuration values. You would typically need to:
    1.  Destroy the infrastructure managed by the stack (if possible, using known credentials outside of Pulumi config).
    2.  Delete the stack (`pulumi stack rm <stack-name>`).
    3.  Initialize a new stack (`pulumi stack init <stack-name>`).
    4.  Re-configure any necessary secrets (`pulumi config set --secret ...`).
    5.  Run `pulumi up` to recreate the infrastructure. 