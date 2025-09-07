#!/usr/bin/env python3
"""
Entry point script for running the FastAPI application.
"""

import uvicorn

from app.core.config import settings

if __name__ == "__main__":
    # Run the FastAPI application using uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=settings.PORT,
        reload=settings.RELOAD,
        log_level="info" if settings.RELOAD else "error",
    )
