#!/usr/bin/env python3
"""
FastAPI Echo App runner using uvicorn.
"""

import logging
import os
import sys

import uvicorn

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)

# Add the parent directory to the path to allow importing from app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))


def run_server(host: str = "0.0.0.0", port: int = 8000, reload: bool = False) -> None:
    """
    Run the FastAPI application using uvicorn.

    Args:
        host: Host to bind the server to
        port: Port to bind the server to
        reload: Whether to enable auto-reload
    """
    try:
        logger.info(f"=== Starting server on {host}:{port} ===")
        logger.info(f"Visit http://localhost:{port}/ or http://localhost:{port}/status")
        logger.info(f"API documentation available at http://localhost:{port}/docs")

        # Run the server using uvicorn
        uvicorn.run(
            "app.web_app:app", host=host, port=port, reload=reload, log_level="info"
        )
    except KeyboardInterrupt:
        logger.info("\n=== Server stopped ===")
    except Exception as e:
        logger.error(f"Error starting server: {e}")
        sys.exit(1)


def parse_args() -> tuple[str, int, bool]:
    """
    Parse command line arguments.

    Returns:
        Tuple of (host, port, reload)
    """
    import argparse

    parser = argparse.ArgumentParser(description="Run the Echo FastAPI App")
    parser.add_argument(
        "--host", type=str, default="0.0.0.0", help="Host to bind the server to"
    )
    parser.add_argument(
        "--port", type=int, default=8000, help="Port to bind the server to"
    )
    parser.add_argument("--reload", action="store_true", help="Enable auto-reload")

    args = parser.parse_args()
    return args.host, args.port, args.reload


def main() -> None:
    """Run the server with command line arguments."""
    host, port, reload = parse_args()
    run_server(host, port, reload)


if __name__ == "__main__":
    main()
