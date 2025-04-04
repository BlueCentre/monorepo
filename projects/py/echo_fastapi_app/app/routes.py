"""
Route handlers for the Echo FastAPI App.
"""

from fastapi import APIRouter, HTTPException
from typing import Dict, Any

from .models import StatusResponse, HealthResponse, EchoResponse

# Create router
router = APIRouter()

@router.get("/", response_model=Dict[str, str])
async def root() -> Dict[str, str]:
    """Root endpoint that returns a simple message."""
    return {"message": "I am alive"}

@router.get("/status", response_model=StatusResponse)
async def status() -> StatusResponse:
    """Status endpoint that returns the application status."""
    return StatusResponse()

@router.get("/health", response_model=HealthResponse)
async def health() -> HealthResponse:
    """Health check endpoint that returns detailed health information."""
    return HealthResponse(
        details={
            "database": "UP",
            "cache": "UP",
            "storage": "UP"
        }
    )

@router.get("/echo/{message}", response_model=EchoResponse)
async def echo(message: str) -> EchoResponse:
    """Echo endpoint that returns the provided message."""
    return EchoResponse(message=message) 