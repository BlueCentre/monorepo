"""
Pydantic models for the Echo FastAPI App.
"""

from typing import Any, Literal

from pydantic import BaseModel, Field


class StatusResponse(BaseModel):
    """Status response model."""

    status: Literal["UP", "DOWN"] = "UP"
    version: str = "0.1.0"

    model_config = {
        "json_schema_extra": {"example": {"status": "UP", "version": "0.1.0"}}
    }


class HealthResponse(BaseModel):
    """Health check response model."""

    status: Literal["UP", "DOWN"] = "UP"
    details: dict[str, Any] = Field(
        default_factory=lambda: {"database": "UP", "cache": "UP", "storage": "UP"}
    )

    model_config = {
        "json_schema_extra": {
            "example": {
                "status": "UP",
                "details": {"database": "UP", "cache": "UP", "storage": "UP"},
            }
        }
    }


class EchoResponse(BaseModel):
    """Echo response model."""

    message: str

    model_config = {"json_schema_extra": {"example": {"message": "Hello, World!"}}}


class ErrorResponse(BaseModel):
    """Error response model."""

    detail: str
    status_code: int

    model_config = {
        "json_schema_extra": {"example": {"detail": "Not Found", "status_code": 404}}
    }
