"""
Rate-limited endpoints with token authentication.
"""

from typing import Any

from fastapi import APIRouter, Depends, Request, Response
from slowapi import Limiter
from slowapi.util import get_remote_address

from app import models
from app.api import deps

router = APIRouter()

# Initialize rate limiter
limiter = Limiter(key_func=get_remote_address)


@router.get("/rate-limited", response_model=dict[str, Any])
@limiter.limit("3/minute")
async def rate_limited_endpoint(
    request: Request,
    response: Response,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Rate-limited endpoint that requires token authentication.

    Limited to 3 requests per minute per IP address.

    Args:
        request: The request object, needed for rate limiter.
        response: The response object.
        current_user: The authenticated user.

    Returns:
        A message confirming the request was successful.
    """
    return {
        "message": "Successfully accessed rate-limited endpoint",
        "user_id": current_user.id,
        "user_email": current_user.email,
    }


@router.get("/rate-limited-user", response_model=dict[str, Any])
@limiter.limit("10/minute", key_func=lambda request: request.state.user_id)
async def rate_limited_by_user(
    request: Request,
    response: Response,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Rate-limited endpoint based on the user ID rather than IP address.

    Limited to 10 requests per minute per user.

    Args:
        request: The request object, needed for rate limiter.
        response: The response object.
        current_user: The authenticated user.

    Returns:
        A message confirming the request was successful.
    """
    # Store user ID in request state for rate limiting
    request.state.user_id = str(current_user.id)

    return {
        "message": "Successfully accessed user-based rate-limited endpoint",
        "user_id": current_user.id,
        "user_email": current_user.email,
    }
