"""
API v1 router.
"""

from fastapi import APIRouter

from app.api.v1.endpoints import (
    items,
    key_management,
    login,
    notes,
    rate_limited,
    seed,
    users,
)

api_router = APIRouter()
api_router.include_router(login.router, tags=["login"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(items.router, prefix="/items", tags=["items"])
api_router.include_router(seed.router, prefix="/seed", tags=["seed"])
api_router.include_router(notes.router, prefix="/notes", tags=["notes"])
api_router.include_router(
    key_management.router, prefix="/key-management", tags=["key-management"]
)
api_router.include_router(
    rate_limited.router, prefix="/rate-limited", tags=["rate-limited"]
)
