"""
Main FastAPI application for the Echo FastAPI App.
"""

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import logging
from typing import Dict, Any

from .models import ErrorResponse
from .routes import router

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

# Create FastAPI app with metadata
app = FastAPI(
    title="Echo FastAPI App",
    description="A simple Echo API built with FastAPI",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(router)

# Event handlers
@app.on_event("startup")
async def startup_event() -> None:
    """Execute actions on application startup."""
    logger.info("=== [Starting FastAPI app...] ===")

@app.on_event("shutdown")
async def shutdown_event() -> None:
    """Execute actions on application shutdown."""
    logger.info("=== [Stopping FastAPI app...] ===")

# Error handling
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """Handle HTTP exceptions."""
    error = ErrorResponse(detail=exc.detail, status_code=exc.status_code)
    return JSONResponse(
        status_code=exc.status_code,
        content=error.dict()
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Handle general exceptions."""
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    error = ErrorResponse(detail="Internal Server Error", status_code=500)
    return JSONResponse(
        status_code=500,
        content=error.dict()
    )
