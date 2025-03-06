#!/usr/bin/env python3

"""
Database migration script for FastAPI template app.

This script runs the database migrations using Alembic.
It can be used as a standalone script or as part of the Bazel build process.
"""

import os
import sys
import argparse
import logging
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def run_migrations(revision="head", sql=False, tag=None):
    """Run database migrations using Alembic."""
    try:
        from alembic.config import Config
        from alembic import command
    except ImportError:
        logger.error("Error: alembic is not installed. Please install it with 'pip install alembic'.")
        sys.exit(1)
    
    # Get the directory containing this script
    script_dir = Path(__file__).parent.absolute()
    
    # Alembic config file
    alembic_cfg = Config(str(script_dir / "alembic.ini"))
    
    # Set the script location, for cases when the CWD is not the script dir
    alembic_cfg.set_main_option("script_location", str(script_dir / "migrations"))
    
    # Get the database URL from the environment or config
    db_url = os.environ.get("SQLALCHEMY_DATABASE_URI")
    if db_url:
        logger.info(f"Using database URL from environment: {db_url}")
        alembic_cfg.set_main_option("sqlalchemy.url", db_url)
    
    # Run the appropriate alembic command
    try:
        if sql:
            logger.info(f"Generating SQL for migration to {revision}")
            command.upgrade(alembic_cfg, revision, sql=True)
        else:
            logger.info(f"Running database migration to {revision}")
            if tag:
                command.upgrade(alembic_cfg, revision, tag=tag)
            else:
                command.upgrade(alembic_cfg, revision)
        logger.info("Migration completed successfully")
    except Exception as e:
        logger.error(f"Error during migration: {e}")
        sys.exit(1)

def main():
    """Parse arguments and run migrations."""
    parser = argparse.ArgumentParser(description="Run database migrations")
    parser.add_argument(
        "--revision", 
        default="head", 
        help="Revision identifier to migrate to (default: head)"
    )
    parser.add_argument(
        "--sql", 
        action="store_true", 
        help="Generate SQL statements instead of running migrations"
    )
    parser.add_argument(
        "--tag", 
        help="Tag to apply to the migration"
    )
    
    args = parser.parse_args()
    run_migrations(args.revision, args.sql, args.tag)

if __name__ == "__main__":
    main() 