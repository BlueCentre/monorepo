"""
API v1 router.
"""

from fastapi import APIRouter

from app.api.v1.endpoints import items, login, users

api_router = APIRouter()
api_router.include_router(login.router, tags=["login"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(items.router, prefix="/items", tags=["items"]) 