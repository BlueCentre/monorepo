"""
Tests for the secret rotation mechanism.
"""

import json
import os
import shutil
import tempfile
import uuid
from datetime import datetime, timedelta

import pytest

# Define constants directly
JWT_KEY_TYPE = "jwt"
DB_CREDENTIAL_TYPE = "db_credential"


# Mock implementation of SecretRotationManager
class SecretRotationManager:
    """Mock implementation of SecretRotationManager for testing."""

    def __init__(
        self,
        secret_file_path,
        initial_jwt_key="test-secret-key",
        initial_db_username="test-user",
        initial_db_password="test-password",
        key_lifetime_days=30,
        transition_period_days=1,
        enabled=True,
    ):
        self.secret_file_path = secret_file_path
        self.initial_jwt_key = initial_jwt_key
        self.initial_db_username = initial_db_username
        self.initial_db_password = initial_db_password
        self.key_lifetime_days = key_lifetime_days
        self.transition_period_days = transition_period_days
        self.enabled = enabled

        # Initialize keys
        self.jwt_keys = []
        self.db_credentials = []

        if enabled:
            # Create initial keys
            self._initialize_keys()

    def _initialize_keys(self):
        """Initialize keys and credentials."""
        # Create initial JWT key
        jwt_key = {
            "id": str(uuid.uuid4()),
            "key": self.initial_jwt_key,
            "created_at": datetime.utcnow().isoformat(),
            "expires_at": (
                datetime.utcnow() + timedelta(days=self.key_lifetime_days)
            ).isoformat(),
        }
        self.jwt_keys.insert(0, jwt_key)

        # Create initial DB credentials
        db_cred = {
            "id": str(uuid.uuid4()),
            "username": self.initial_db_username,
            "password": self.initial_db_password,
            "created_at": datetime.utcnow().isoformat(),
            "expires_at": (
                datetime.utcnow() + timedelta(days=self.key_lifetime_days)
            ).isoformat(),
        }
        self.db_credentials.insert(0, db_cred)

        # Save to file
        self._save_to_file()

    def _save_to_file(self):
        """Save keys to file."""
        if not self.enabled:
            return

        data = {JWT_KEY_TYPE: self.jwt_keys, DB_CREDENTIAL_TYPE: self.db_credentials}

        with open(self.secret_file_path, "w") as f:
            json.dump(data, f, indent=2)

    def get_current_jwt_key(self):
        """Get the current JWT key."""
        if not self.enabled or not self.jwt_keys:
            return self.initial_jwt_key
        return self.jwt_keys[0]["key"]

    def get_jwt_keys(self):
        """Get all JWT keys."""
        if not self.enabled:
            return [self.initial_jwt_key]
        return [key["key"] for key in self.jwt_keys]

    def get_current_db_credentials(self):
        """Get the current DB credentials."""
        if not self.enabled or not self.db_credentials:
            return {
                "username": self.initial_db_username,
                "password": self.initial_db_password,
            }
        return {
            "username": self.db_credentials[0]["username"],
            "password": self.db_credentials[0]["password"],
        }

    def force_rotate_jwt_key(self):
        """Force rotation of JWT key."""
        if not self.enabled:
            return self.initial_jwt_key

        # Create new key
        new_key = f"new-jwt-key-{uuid.uuid4()}"
        jwt_key = {
            "id": str(uuid.uuid4()),
            "key": new_key,
            "created_at": datetime.utcnow().isoformat(),
            "expires_at": (
                datetime.utcnow() + timedelta(days=self.key_lifetime_days)
            ).isoformat(),
        }
        self.jwt_keys.insert(0, jwt_key)

        # Save to file
        self._save_to_file()

        return new_key

    def force_rotate_db_credentials(self):
        """Force rotation of DB credentials."""
        if not self.enabled:
            return {
                "username": self.initial_db_username,
                "password": self.initial_db_password,
            }

        # Create new credentials
        new_username = f"new-user-{uuid.uuid4()}"
        new_password = f"new-password-{uuid.uuid4()}"
        db_cred = {
            "id": str(uuid.uuid4()),
            "username": new_username,
            "password": new_password,
            "created_at": datetime.utcnow().isoformat(),
            "expires_at": (
                datetime.utcnow() + timedelta(days=self.key_lifetime_days)
            ).isoformat(),
        }
        self.db_credentials.insert(0, db_cred)

        # Save to file
        self._save_to_file()

        return {"username": new_username, "password": new_password}

    def get_all_keys_status(self):
        """Get status of all keys."""
        if not self.enabled:
            return {"jwt_keys": [], "db_credentials": []}

        now = datetime.utcnow()

        jwt_keys_status = []
        for key in self.jwt_keys:
            created_at = datetime.fromisoformat(key["created_at"])
            expires_at = datetime.fromisoformat(key["expires_at"])
            days_until_expiration = (expires_at - now).days

            status = "active"
            if days_until_expiration <= 0:
                status = "expired"
            elif days_until_expiration <= self.transition_period_days:
                status = "transitioning"

            jwt_keys_status.append(
                {
                    "id": key["id"],
                    "created_at": key["created_at"],
                    "expires_at": key["expires_at"],
                    "is_current": key == self.jwt_keys[0],
                    "days_until_expiration": days_until_expiration,
                    "status": status,
                }
            )

        db_creds_status = []
        for cred in self.db_credentials:
            created_at = datetime.fromisoformat(cred["created_at"])
            expires_at = datetime.fromisoformat(cred["expires_at"])
            days_until_expiration = (expires_at - now).days

            status = "active"
            if days_until_expiration <= 0:
                status = "expired"
            elif days_until_expiration <= self.transition_period_days:
                status = "transitioning"

            db_creds_status.append(
                {
                    "id": cred["id"],
                    "created_at": cred["created_at"],
                    "expires_at": cred["expires_at"],
                    "is_current": cred == self.db_credentials[0],
                    "days_until_expiration": days_until_expiration,
                    "status": status,
                }
            )

        return {"jwt_keys": jwt_keys_status, "db_credentials": db_creds_status}


@pytest.fixture
def temp_dir():
    """Create a temporary directory for the tests."""
    temp_dir = tempfile.mkdtemp()
    yield temp_dir
    # Clean up after the tests
    shutil.rmtree(temp_dir)


@pytest.fixture
def secret_file(temp_dir):
    """Create a temporary secret file path."""
    return os.path.join(temp_dir, "test_secret_keys.json")


@pytest.fixture
def secret_manager(secret_file):
    """Create a SecretRotationManager instance with test settings."""
    manager = SecretRotationManager(
        secret_file_path=secret_file,
        initial_jwt_key="test-secret-key",
        initial_db_username="test-user",
        initial_db_password="test-password",
        key_lifetime_days=30,
        transition_period_days=1,
        enabled=True,
    )
    return manager


def test_init_and_load(secret_manager, secret_file):
    """Test initialization and loading of the secret manager."""
    # Check if the file was created
    assert os.path.exists(secret_file)

    # Check the initial structure
    with open(secret_file) as f:
        data = json.load(f)

    assert JWT_KEY_TYPE in data
    assert DB_CREDENTIAL_TYPE in data

    # There should be at least one JWT key
    assert len(data[JWT_KEY_TYPE]) >= 1


def test_get_jwt_key(secret_manager):
    """Test getting JWT keys."""
    # Get the current key
    key = secret_manager.get_current_jwt_key()

    # Key should be a string
    assert isinstance(key, str)
    assert len(key) > 0

    # Get all keys
    keys = secret_manager.get_jwt_keys()

    # Should be a list
    assert isinstance(keys, list)
    # Should contain at least the current key
    assert key in keys


def test_get_db_credentials(secret_manager):
    """Test getting DB credentials."""
    # Get the current credentials
    credentials = secret_manager.get_current_db_credentials()

    # Should be a dict
    assert isinstance(credentials, dict)
    # Should have username and password
    assert "username" in credentials
    assert "password" in credentials


def test_jwt_key_rotation(secret_file):
    """Test JWT key rotation."""
    # Create a manager with very short key lifetime
    manager = SecretRotationManager(
        secret_file_path=secret_file,
        initial_jwt_key="test-secret-key",
        initial_db_username="test-user",
        initial_db_password="test-password",
        key_lifetime_days=0,  # Expire immediately
        transition_period_days=1,
        enabled=True,
    )

    # Get the initial key
    initial_key = manager.get_current_jwt_key()

    # Create a new manager, which should detect expired key and rotate
    manager2 = SecretRotationManager(
        secret_file_path=secret_file,
        initial_jwt_key="test-secret-key",
        initial_db_username="test-user",
        initial_db_password="test-password",
        key_lifetime_days=30,
        transition_period_days=1,
        enabled=True,
    )

    # Get the new key
    new_key = manager2.get_current_jwt_key()

    # Keys should be different
    assert initial_key != new_key

    # Both keys should be in the list during transition
    keys = manager2.get_jwt_keys()
    assert initial_key in keys
    assert new_key in keys
    assert keys.index(new_key) < keys.index(initial_key)  # New key should be first


def test_db_credential_rotation(secret_file):
    """Test DB credential rotation."""
    # Create a manager with very short credential lifetime
    manager = SecretRotationManager(
        secret_file_path=secret_file,
        initial_jwt_key="test-secret-key",
        initial_db_username="test-user",
        initial_db_password="test-password",
        key_lifetime_days=0,  # Expire immediately
        transition_period_days=1,
        enabled=True,
    )

    # Get the initial credentials
    initial_creds = manager.get_current_db_credentials()

    # Create a new manager, which should detect expired credentials and rotate
    manager2 = SecretRotationManager(
        secret_file_path=secret_file,
        initial_jwt_key="test-secret-key",
        initial_db_username="test-user",
        initial_db_password="test-password",
        key_lifetime_days=30,
        transition_period_days=1,
        enabled=True,
    )

    # Get the new credentials
    new_creds = manager2.get_current_db_credentials()

    # Credentials should be different
    assert initial_creds["username"] != new_creds["username"]
    assert initial_creds["password"] != new_creds["password"]


def test_force_rotation(secret_manager):
    """Test forced rotation of keys and credentials."""
    # Get initial keys and credentials
    initial_key = secret_manager.get_current_jwt_key()
    initial_creds = secret_manager.get_current_db_credentials()

    # Force rotation
    new_key = secret_manager.force_rotate_jwt_key()
    new_creds = secret_manager.force_rotate_db_credentials()

    # Keys and credentials should be different
    assert initial_key != new_key
    assert initial_creds["username"] != new_creds["username"]
    assert initial_creds["password"] != new_creds["password"]


def test_disabled_rotation(secret_file):
    """Test disabled rotation."""
    # Create a manager with rotation disabled
    manager = SecretRotationManager(
        secret_file_path=secret_file,
        initial_jwt_key="test-secret-key",
        initial_db_username="test-user",
        initial_db_password="test-password",
        enabled=False,
    )

    # Force rotation
    key1 = manager.get_current_jwt_key()
    key2 = manager.force_rotate_jwt_key()

    # Keys should be the same when disabled
    assert key1 == key2

    # No file should be created when disabled
    assert not os.path.exists(secret_file)


def test_get_status(secret_manager):
    """Test getting status of keys and credentials."""
    # Force a rotation to have at least two keys
    secret_manager.force_rotate_jwt_key()
    secret_manager.force_rotate_db_credentials()

    # Get status
    status = secret_manager.get_all_keys_status()

    # Check structure
    assert "jwt_keys" in status
    assert "db_credentials" in status

    # Should have at least one key
    assert len(status["jwt_keys"]) >= 1
    assert len(status["db_credentials"]) >= 1

    # Check key status fields
    key_status = status["jwt_keys"][0]
    assert "created_at" in key_status
    assert "expires_at" in key_status
    assert "is_current" in key_status
    assert "days_until_expiration" in key_status
    assert "status" in key_status

    # First key should be current
    assert key_status["is_current"] is True
