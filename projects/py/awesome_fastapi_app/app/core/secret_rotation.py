"""
Secret Rotation Mechanism.

This module handles the rotation of application secrets to enhance security.
It implements a key rotation strategy where multiple keys can be active simultaneously
during a transition period, allowing for smooth rotation without service disruption.
"""

import json
import logging
import os
import secrets
import time
from datetime import datetime, timedelta
from typing import Any

from app.core.config import settings

logger = logging.getLogger(__name__)

# Define key types
JWT_KEY_TYPE = "jwt"
DB_CREDENTIAL_TYPE = "db_credential"


class SecretRotationManager:
    """Manages the rotation of application secrets."""

    def __init__(
        self,
        secret_file_path: str | None = None,
        transition_period_days: int | None = None,
        key_lifetime_days: int | None = None,
        enabled: bool = True,
    ):
        """
        Initialize the Secret Rotation Manager.

        Args:
            secret_file_path: Path to store the secret keys
            transition_period_days: Number of days to keep old keys active during transition
            key_lifetime_days: Number of days before rotating keys
            enabled: Whether secret rotation is enabled
        """
        self.enabled = enabled

        # Use settings from config if not provided
        self.transition_period = timedelta(
            days=transition_period_days
            if transition_period_days is not None
            else settings.SECRET_KEY_TRANSITION_DAYS
        )
        self.key_lifetime = timedelta(
            days=key_lifetime_days
            if key_lifetime_days is not None
            else settings.SECRET_KEY_LIFETIME_DAYS
        )

        # Default storage location in /tmp for dev, should be a secure location in production
        if secret_file_path is None:
            self.secrets_dir = os.environ.get(
                "SECRETS_DIR",
                os.path.join(
                    os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                    "secrets",
                ),
            )
            os.makedirs(self.secrets_dir, exist_ok=True)
            self.secret_file_path = os.path.join(self.secrets_dir, "secret_keys.json")
        else:
            self.secret_file_path = secret_file_path
            self.secrets_dir = os.path.dirname(secret_file_path)
            os.makedirs(self.secrets_dir, exist_ok=True)

        # Load or initialize secrets
        self.secrets = self._load_secrets()

        # If we have a SECRET_KEY in settings but no JWT keys, add it as the initial key
        if (
            not self.secrets[JWT_KEY_TYPE]
            and hasattr(settings, "SECRET_KEY")
            and settings.SECRET_KEY
        ):
            now = datetime.utcnow().isoformat()
            self.secrets[JWT_KEY_TYPE].append(
                {
                    "key": settings.SECRET_KEY,
                    "created_at": now,
                    "expires_at": (datetime.utcnow() + self.key_lifetime).isoformat(),
                    "source": "config",
                }
            )
            logger.info("Added SECRET_KEY from config as the initial JWT key")
            self._save_secrets()

    def _load_secrets(self) -> dict[str, Any]:
        """Load secrets from file or initialize if not exists."""
        try:
            if os.path.exists(self.secret_file_path):
                with open(self.secret_file_path) as f:
                    secrets_data = json.load(f)
                logger.info(f"Loaded secrets from {self.secret_file_path}")
                return secrets_data
            else:
                logger.info(
                    f"No secrets file found at {self.secret_file_path}, initializing new secrets"
                )
                # Initialize with default structure
                return {
                    JWT_KEY_TYPE: [],
                    DB_CREDENTIAL_TYPE: [],
                }
        except Exception as e:
            logger.error(f"Error loading secrets: {e}")
            # Return empty structure on error
            return {
                JWT_KEY_TYPE: [],
                DB_CREDENTIAL_TYPE: [],
            }

    def _save_secrets(self) -> None:
        """Save secrets to file."""
        if not self.enabled:
            logger.debug("Secret rotation is disabled, not saving secrets")
            return

        try:
            with open(self.secret_file_path, "w") as f:
                json.dump(self.secrets, f, indent=2)
            logger.info(f"Saved secrets to {self.secret_file_path}")

            # Set secure permissions
            os.chmod(self.secret_file_path, 0o600)
        except Exception as e:
            logger.error(f"Error saving secrets: {e}")

    def _generate_jwt_key(self) -> str:
        """Generate a new JWT signing key."""
        return secrets.token_urlsafe(32)

    def _generate_db_credential(self) -> dict[str, str]:
        """Generate new database credentials."""
        return {
            "username": f"db_user_{int(time.time())}",
            "password": secrets.token_urlsafe(16),
        }

    def get_current_jwt_key(self) -> str:
        """
        Get the current JWT signing key.

        If no keys exist or the current key has expired, a new key is generated.

        Returns:
            The current JWT signing key.
        """
        if not self.enabled:
            # If rotation is disabled, use the SECRET_KEY from settings
            return settings.SECRET_KEY

        self._rotate_jwt_keys_if_needed()

        if not self.secrets[JWT_KEY_TYPE]:
            # Create a new key if none exists
            self._add_new_jwt_key()

        # Return the most recent key
        return self.secrets[JWT_KEY_TYPE][0]["key"]

    def get_jwt_keys(self) -> list[str]:
        """
        Get all active JWT signing keys.

        Returns:
            List of active JWT signing keys, with the newest first.
        """
        if not self.enabled:
            # If rotation is disabled, just return the SECRET_KEY from settings
            return [settings.SECRET_KEY]

        self._rotate_jwt_keys_if_needed()

        # Return all active keys
        return [key_entry["key"] for key_entry in self.secrets[JWT_KEY_TYPE]]

    def get_current_db_credentials(self) -> dict[str, str]:
        """
        Get the current database credentials.

        If no credentials exist or the current credentials have expired,
        new credentials are generated.

        Returns:
            The current database credentials.
        """
        if not self.enabled:
            # If rotation is disabled, use the database credentials from settings
            return {
                "username": settings.POSTGRES_USER,
                "password": settings.POSTGRES_PASSWORD,
            }

        self._rotate_db_credentials_if_needed()

        if not self.secrets[DB_CREDENTIAL_TYPE]:
            # Create new credentials if none exist
            self._add_new_db_credentials()

        # Return the most recent credentials
        return self.secrets[DB_CREDENTIAL_TYPE][0]["credentials"]

    def _add_new_jwt_key(self) -> None:
        """Add a new JWT signing key."""
        if not self.enabled:
            return

        new_key = self._generate_jwt_key()
        now = datetime.utcnow().isoformat()

        # Add the new key at the beginning of the list
        self.secrets[JWT_KEY_TYPE].insert(
            0,
            {
                "key": new_key,
                "created_at": now,
                "expires_at": (datetime.utcnow() + self.key_lifetime).isoformat(),
                "source": "rotation",
            },
        )

        self._save_secrets()
        logger.info("Generated and saved new JWT signing key")

    def _add_new_db_credentials(self) -> None:
        """Add new database credentials."""
        if not self.enabled:
            return

        new_credentials = self._generate_db_credential()
        now = datetime.utcnow().isoformat()

        # Add the new credentials at the beginning of the list
        self.secrets[DB_CREDENTIAL_TYPE].insert(
            0,
            {
                "credentials": new_credentials,
                "created_at": now,
                "expires_at": (datetime.utcnow() + self.key_lifetime).isoformat(),
            },
        )

        self._save_secrets()
        logger.info("Generated and saved new database credentials")

    def _rotate_jwt_keys_if_needed(self) -> None:
        """Check if JWT keys need rotation and perform rotation if necessary."""
        if not self.enabled:
            return

        now = datetime.utcnow()
        keys_to_remove = []
        current_key_expired = False

        # Check for expired keys and mark keys for removal
        for i, key_entry in enumerate(self.secrets[JWT_KEY_TYPE]):
            expires_at = datetime.fromisoformat(key_entry["expires_at"])

            if i == 0 and expires_at <= now:
                # The current key has expired, we need to create a new one
                current_key_expired = True

            # Remove keys that are expired and beyond the transition period
            if expires_at + self.transition_period <= now:
                keys_to_remove.append(i)

        # Remove expired keys (in reverse order to maintain correct indices)
        for i in sorted(keys_to_remove, reverse=True):
            logger.info(
                f"Removing expired JWT key created at {self.secrets[JWT_KEY_TYPE][i]['created_at']}"
            )
            self.secrets[JWT_KEY_TYPE].pop(i)

        # Add a new key if the current one expired
        if current_key_expired or not self.secrets[JWT_KEY_TYPE]:
            self._add_new_jwt_key()

    def _rotate_db_credentials_if_needed(self) -> None:
        """Check if database credentials need rotation and perform rotation if necessary."""
        if not self.enabled:
            return

        now = datetime.utcnow()
        credentials_to_remove = []
        current_credentials_expired = False

        # Check for expired credentials and mark for removal
        for i, cred_entry in enumerate(self.secrets[DB_CREDENTIAL_TYPE]):
            expires_at = datetime.fromisoformat(cred_entry["expires_at"])

            if i == 0 and expires_at <= now:
                # The current credentials have expired, we need to create new ones
                current_credentials_expired = True

            # Remove credentials that are expired and beyond the transition period
            if expires_at + self.transition_period <= now:
                credentials_to_remove.append(i)

        # Remove expired credentials (in reverse order to maintain correct indices)
        for i in sorted(credentials_to_remove, reverse=True):
            logger.info(
                f"Removing expired database credentials created at {self.secrets[DB_CREDENTIAL_TYPE][i]['created_at']}"
            )
            self.secrets[DB_CREDENTIAL_TYPE].pop(i)

        # Add new credentials if the current ones expired
        if current_credentials_expired or not self.secrets[DB_CREDENTIAL_TYPE]:
            self._add_new_db_credentials()

    def force_rotate_jwt_key(self) -> str:
        """
        Force rotation of the JWT signing key.

        Returns:
            The new JWT signing key.
        """
        if not self.enabled:
            return settings.SECRET_KEY

        self._add_new_jwt_key()
        return self.secrets[JWT_KEY_TYPE][0]["key"]

    def force_rotate_db_credentials(self) -> dict[str, str]:
        """
        Force rotation of the database credentials.

        Returns:
            The new database credentials.
        """
        if not self.enabled:
            return {
                "username": settings.POSTGRES_USER,
                "password": settings.POSTGRES_PASSWORD,
            }

        self._add_new_db_credentials()
        return self.secrets[DB_CREDENTIAL_TYPE][0]["credentials"]

    def get_all_keys_status(self) -> dict[str, list[dict[str, Any]]]:
        """
        Get the status of all keys.

        Returns:
            A dictionary with the status of all keys.
        """
        now = datetime.utcnow()

        if not self.enabled:
            # If rotation is disabled, return minimal info
            return {
                "jwt_keys": [
                    {
                        "created_at": "N/A",
                        "expires_at": "N/A",
                        "is_current": True,
                        "days_until_expiration": "N/A",
                        "status": "active (rotation disabled)",
                    }
                ],
                "db_credentials": [
                    {
                        "created_at": "N/A",
                        "expires_at": "N/A",
                        "username": settings.POSTGRES_USER,
                        "is_current": True,
                        "days_until_expiration": "N/A",
                        "status": "active (rotation disabled)",
                    }
                ],
            }

        # Build status for JWT keys
        jwt_keys_status = []
        for key_entry in self.secrets[JWT_KEY_TYPE]:
            expires_at = datetime.fromisoformat(key_entry["expires_at"])
            jwt_keys_status.append(
                {
                    "created_at": key_entry["created_at"],
                    "expires_at": key_entry["expires_at"],
                    "is_current": key_entry == self.secrets[JWT_KEY_TYPE][0],
                    "days_until_expiration": (expires_at - now).days,
                    "status": "active" if expires_at > now else "expired",
                    "source": key_entry.get("source", "unknown"),
                }
            )

        # Build status for DB credentials
        db_credentials_status = []
        for cred_entry in self.secrets[DB_CREDENTIAL_TYPE]:
            expires_at = datetime.fromisoformat(cred_entry["expires_at"])
            db_credentials_status.append(
                {
                    "created_at": cred_entry["created_at"],
                    "expires_at": cred_entry["expires_at"],
                    "username": cred_entry["credentials"]["username"],
                    "is_current": cred_entry == self.secrets[DB_CREDENTIAL_TYPE][0],
                    "days_until_expiration": (expires_at - now).days,
                    "status": "active" if expires_at > now else "expired",
                }
            )

        return {
            "jwt_keys": jwt_keys_status,
            "db_credentials": db_credentials_status,
        }


# Create a singleton instance for global use
secret_manager = SecretRotationManager(enabled=settings.SECRET_ROTATION_ENABLED)
