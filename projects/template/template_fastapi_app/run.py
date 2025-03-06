"""
Script to run the FastAPI application.
"""

import logging
import uvicorn

from app.core.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def main() -> None:
    """
    Run the FastAPI application.
    """
    logger.info(f"Starting {settings.PROJECT_NAME}")
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=settings.PORT,
        reload=settings.RELOAD,
        log_level="info",
    )


if __name__ == "__main__":
    main() 