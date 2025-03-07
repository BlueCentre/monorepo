"""
Key management endpoints for handling JWT key rotation and DB credential rotation.
"""

from datetime import datetime
from typing import Dict, Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.api import deps
from app.core.secret_rotation import secret_manager

router = APIRouter()


class KeyStatusResponse(BaseModel):
    """Response model for key status."""
    jwt_keys: List[Dict[str, Any]]
    db_credentials: List[Dict[str, Any]]
    rotation_enabled: bool
    current_time: str


class KeyRotationResponse(BaseModel):
    """Response model for key rotation."""
    success: bool
    message: str
    rotated_at: str


@router.get("/status", response_model=KeyStatusResponse)
def get_key_status(
    current_user = Depends(deps.get_current_active_superuser)
) -> Any:
    """
    Get the status of all JWT keys and DB credentials.
    
    Only accessible to superusers.
    """
    status = secret_manager.get_all_keys_status()
    
    return {
        "jwt_keys": status["jwt_keys"],
        "db_credentials": status["db_credentials"],
        "rotation_enabled": secret_manager.enabled,
        "current_time": datetime.utcnow().isoformat()
    }


@router.post("/rotate-jwt-key", response_model=KeyRotationResponse)
def rotate_jwt_key(
    current_user = Depends(deps.get_current_active_superuser)
) -> Any:
    """
    Force rotation of the JWT signing key.
    
    Only accessible to superusers.
    """
    if not secret_manager.enabled:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Secret rotation is disabled"
        )
    
    try:
        secret_manager.force_rotate_jwt_key()
        return {
            "success": True,
            "message": "JWT key rotated successfully",
            "rotated_at": datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to rotate JWT key: {str(e)}"
        )


@router.post("/rotate-db-credentials", response_model=KeyRotationResponse)
def rotate_db_credentials(
    current_user = Depends(deps.get_current_active_superuser)
) -> Any:
    """
    Force rotation of the DB credentials.
    
    Only accessible to superusers.
    
    Note: This will only rotate credentials in the application's secret store.
    Database credentials must be updated separately in the actual database.
    """
    if not secret_manager.enabled:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Secret rotation is disabled"
        )
    
    try:
        credentials = secret_manager.force_rotate_db_credentials()
        return {
            "success": True,
            "message": f"DB credentials rotated successfully. New username: {credentials['username']}",
            "rotated_at": datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to rotate DB credentials: {str(e)}"
        ) 