"""
Security utilities for authentication.
"""

from datetime import datetime, timedelta
from typing import Any

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings
from app.core.secret_rotation import secret_manager

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def create_access_token(
    subject: str | Any, expires_delta: timedelta | None = None
) -> str:
    """
    Create a JWT access token.

    Args:
        subject: Subject of the token (usually user ID).
        expires_delta: Expiration time delta.

    Returns:
        JWT access token.
    """
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
    to_encode = {"exp": expire, "sub": str(subject)}

    # Use the current JWT key from the rotation manager
    secret_key = secret_manager.get_current_jwt_key()
    encoded_jwt = jwt.encode(to_encode, secret_key, algorithm=settings.ALGORITHM)
    return encoded_jwt


def verify_token(token: str) -> str | None:
    """
    Verify a JWT token and return the subject.

    This function tries all active keys when verifying tokens to allow
    for smooth key rotation.

    Args:
        token: JWT token to verify.

    Returns:
        The subject of the token if valid, None otherwise.
    """
    # Get all active JWT keys
    jwt_keys = secret_manager.get_jwt_keys()

    # Try each key until one works
    for key in jwt_keys:
        try:
            payload = jwt.decode(token, key, algorithms=[settings.ALGORITHM])
            return payload.get("sub")
        except JWTError:
            continue

    # If no key works, the token is invalid
    return None


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a password against a hash.

    Args:
        plain_password: Plain password.
        hashed_password: Hashed password.

    Returns:
        True if the password matches the hash, False otherwise.
    """
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """
    Hash a password.

    Args:
        password: Plain password.

    Returns:
        Hashed password.
    """
    return pwd_context.hash(password)
