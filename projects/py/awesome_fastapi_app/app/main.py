"""
Main FastAPI application.
"""

import logging
from typing import Any

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address
from starlette.middleware.base import BaseHTTPMiddleware

from app.api.v1.api import api_router
from app.core.config import settings
from app.core.telemetry import setup_telemetry
from app.db.session import engine

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware for logging requests."""

    async def dispatch(self, request: Request, call_next: Any) -> Any:
        """
        Log request information.

        Args:
            request: Request object.
            call_next: Next middleware.

        Returns:
            Response from the next middleware.
        """
        logger.info(f"Request: {request.method} {request.url.path}")
        response = await call_next(request)
        logger.info(f"Response status: {response.status_code}")
        return response


# Initialize rate limiter
limiter = Limiter(key_func=get_remote_address)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    description="FastAPI application with PostgreSQL, PubSub, and more.",
    version="0.1.0",
    docs_url="/swagger",
    redoc_url="/docs",
)

# Add rate limiter to app state and exception handler
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Set all CORS enabled origins
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# Add request logging middleware
app.add_middleware(RequestLoggingMiddleware)

# Set up OpenTelemetry
if settings.ENABLE_TELEMETRY:
    setup_telemetry(
        app=app,
        sqlalchemy_engine=engine,
        service_name=settings.OTLP_SERVICE_NAME,
        exporter_endpoint=settings.OTLP_EXPORTER_ENDPOINT,
    )


@app.get("/")
def root() -> Any:
    """
    Root endpoint.

    Returns:
        Welcome message.
    """
    return {"message": f"Welcome to {settings.PROJECT_NAME}"}


@app.get("/health")
def health() -> Any:
    """
    Health check endpoint.

    Returns:
        Health status.
    """
    return {"status": "ok"}


# Include API router
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """
    Global exception handler.

    Args:
        request: Request object.
        exc: Exception.

    Returns:
        JSON response with error details.
    """
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )
