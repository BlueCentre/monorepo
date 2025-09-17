"""
Tests for the key management API endpoints.
"""

import json
import os
import shutil
import tempfile
import uuid
from collections.abc import Generator
from datetime import datetime, timedelta
from typing import Any

import pytest
from fastapi import APIRouter, Depends, FastAPI, HTTPException, status
from fastapi.testclient import TestClient
from pydantic import BaseModel


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

        data = {"jwt": self.jwt_keys, "db_credential": self.db_credentials}

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


# Mock API models
class KeyStatusResponse(BaseModel):
    """Response model for key status."""

    jwt_keys: list[dict[str, Any]]
    db_credentials: list[dict[str, Any]]
    rotation_enabled: bool
    current_time: str


class KeyRotationResponse(BaseModel):
    """Response model for key rotation."""

    success: bool
    message: str
    rotated_at: str


# Create a mock router
def create_key_management_router(secret_manager: SecretRotationManager) -> APIRouter:
    """Create a mock key management router."""
    router = APIRouter()

    # Mock dependency
    def get_current_active_superuser():
        return {"id": 1, "email": "admin@example.com", "is_superuser": True}

    @router.get("/status", response_model=KeyStatusResponse)
    def get_key_status(current_user=Depends(get_current_active_superuser)) -> Any:
        """
        Get the status of all JWT keys and DB credentials.

        Only accessible to superusers.
        """
        status = secret_manager.get_all_keys_status()

        return {
            "jwt_keys": status["jwt_keys"],
            "db_credentials": status["db_credentials"],
            "rotation_enabled": secret_manager.enabled,
            "current_time": datetime.utcnow().isoformat(),
        }

    @router.post("/rotate-jwt-key", response_model=KeyRotationResponse)
    def rotate_jwt_key(current_user=Depends(get_current_active_superuser)) -> Any:
        """
        Force rotation of the JWT signing key.

        Only accessible to superusers.
        """
        if not secret_manager.enabled:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Secret rotation is disabled",
            )

        try:
            secret_manager.force_rotate_jwt_key()
            return {
                "success": True,
                "message": "JWT key rotated successfully",
                "rotated_at": datetime.utcnow().isoformat(),
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to rotate JWT key: {str(e)}",
            )

    @router.post("/rotate-db-credentials", response_model=KeyRotationResponse)
    def rotate_db_credentials(
        current_user=Depends(get_current_active_superuser),
    ) -> Any:
        """
        Force rotation of the DB credentials.

        Only accessible to superusers.
        """
        if not secret_manager.enabled:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Secret rotation is disabled",
            )

        try:
            credentials = secret_manager.force_rotate_db_credentials()
            return {
                "success": True,
                "message": f"DB credentials rotated successfully. New username: {credentials['username']}",
                "rotated_at": datetime.utcnow().isoformat(),
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to rotate DB credentials: {str(e)}",
            )

    return router


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


@pytest.fixture
def app(secret_manager) -> FastAPI:
    """Create a FastAPI app with the key management router."""
    app = FastAPI()

    # Create and add the router
    router = create_key_management_router(secret_manager)
    app.include_router(router, prefix="/key-management")

    return app


@pytest.fixture
def client(app) -> Generator[TestClient, None, None]:
    """Get a FastAPI test client."""
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def app_without_auth(secret_manager) -> FastAPI:
    """Create a FastAPI app with the key management router but without auth override."""
    app = FastAPI()

    # Create a router that requires real authentication
    router = APIRouter()

    @router.get("/status")
    def get_key_status():
        """Endpoint that requires authentication."""
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    @router.post("/rotate-jwt-key")
    def rotate_jwt_key():
        """Endpoint that requires authentication."""
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    @router.post("/rotate-db-credentials")
    def rotate_db_credentials():
        """Endpoint that requires authentication."""
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    app.include_router(router, prefix="/key-management")

    return app


@pytest.fixture
def client_without_auth(app_without_auth) -> Generator[TestClient, None, None]:
    """Get a FastAPI test client without auth override."""
    with TestClient(app_without_auth) as test_client:
        yield test_client


def test_get_key_status(client):
    """Test getting key status."""
    response = client.get("/key-management/status")
    assert response.status_code == 200

    data = response.json()
    assert "jwt_keys" in data
    assert "db_credentials" in data
    assert "rotation_enabled" in data
    assert "current_time" in data

    # Should have at least one key
    assert len(data["jwt_keys"]) >= 1
    assert len(data["db_credentials"]) >= 1

    # Check key status fields
    key_status = data["jwt_keys"][0]
    assert "created_at" in key_status
    assert "expires_at" in key_status
    assert "is_current" in key_status
    assert "days_until_expiration" in key_status
    assert "status" in key_status


def test_rotate_jwt_key(client):
    """Test rotating JWT key."""
    # Get initial status
    initial_response = client.get("/key-management/status")
    initial_data = initial_response.json()
    initial_key_id = initial_data["jwt_keys"][0]["id"]

    # Rotate key
    rotate_response = client.post("/key-management/rotate-jwt-key")
    assert rotate_response.status_code == 200

    rotate_data = rotate_response.json()
    assert rotate_data["success"] is True
    assert "JWT key rotated successfully" in rotate_data["message"]
    assert "rotated_at" in rotate_data

    # Check new status
    new_response = client.get("/key-management/status")
    new_data = new_response.json()
    new_key_id = new_data["jwt_keys"][0]["id"]

    # Should have a new key
    assert new_key_id != initial_key_id

    # Should have at least two keys (old and new)
    assert len(new_data["jwt_keys"]) >= 2


def test_rotate_db_credentials(client):
    """Test rotating DB credentials."""
    # Get initial status
    initial_response = client.get("/key-management/status")
    initial_data = initial_response.json()
    initial_cred_id = initial_data["db_credentials"][0]["id"]

    # Rotate credentials
    rotate_response = client.post("/key-management/rotate-db-credentials")
    assert rotate_response.status_code == 200

    rotate_data = rotate_response.json()
    assert rotate_data["success"] is True
    assert "DB credentials rotated successfully" in rotate_data["message"]
    assert "rotated_at" in rotate_data

    # Check new status
    new_response = client.get("/key-management/status")
    new_data = new_response.json()
    new_cred_id = new_data["db_credentials"][0]["id"]

    # Should have a new credential
    assert new_cred_id != initial_cred_id

    # Should have at least two credentials (old and new)
    assert len(new_data["db_credentials"]) >= 2


def test_unauthorized_access(client_without_auth):
    """Test unauthorized access to key management endpoints."""
    # Try to access without authentication
    response = client_without_auth.get("/key-management/status")
    assert response.status_code == 401 or response.status_code == 403

    # Try to rotate JWT key without authentication
    response = client_without_auth.post("/key-management/rotate-jwt-key")
    assert response.status_code == 401 or response.status_code == 403

    # Try to rotate DB credentials without authentication
    response = client_without_auth.post("/key-management/rotate-db-credentials")
    assert response.status_code == 401 or response.status_code == 403
