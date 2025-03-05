from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import logging
import traceback
from typing import Dict, Any

from .routes import router
from .models import ErrorResponse

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="DevOps FastAPI App",
    description="A modern FastAPI application for DevOps-related operations",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include router
app.include_router(router)


# Exception handlers
@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """
    Global exception handler for unhandled exceptions.
    
    Args:
        request: The request that caused the exception.
        exc: The exception that was raised.
        
    Returns:
        JSONResponse: A JSON response with error details.
    """
    logger.error(f"Unhandled exception: {str(exc)}")
    logger.error(traceback.format_exc())
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content=ErrorResponse(
            detail="Internal server error",
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
        ).model_dump(),
    )


# Application startup and shutdown events
@app.on_event("startup")
async def startup_event() -> None:
    """
    Executes when the application starts up.
    """
    logger.info("DevOps FastAPI application starting up...")


@app.on_event("shutdown")
async def shutdown_event() -> None:
    """
    Executes when the application is shutting down.
    """
    logger.info("DevOps FastAPI application shutting down...") 