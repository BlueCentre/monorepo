"""
Token schemas.
"""

from typing import Optional

from pydantic import BaseModel


class Token(BaseModel):
    """
    Token schema.
    
    Attributes:
        access_token: JWT access token.
        token_type: Type of token.
    """
    
    access_token: str
    token_type: str


class TokenPayload(BaseModel):
    """
    Token payload schema.
    
    Attributes:
        sub: Subject of the token (user ID).
        exp: Expiration time of the token.
    """
    
    sub: Optional[int] = None
    exp: Optional[int] = None 