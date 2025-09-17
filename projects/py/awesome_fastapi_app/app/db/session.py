"""
Database session management.
"""

import logging

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.db.base_class import Base

logger = logging.getLogger(__name__)

# Create SQLAlchemy engine
try:
    # Handle the case where port might be a full TCP URL
    port = settings.POSTGRES_PORT
    if isinstance(port, str) and port.startswith("tcp://"):
        # Extract just the port number from the end
        port = port.split(":")[-1]

    # Handle the case where server might also be a TCP URL
    server = settings.POSTGRES_SERVER
    if isinstance(server, str) and server.startswith("tcp://"):
        # Extract just the server address
        server = server.split("//")[1].split(":")[0]

    # Create database URI regardless of whether settings.SQLALCHEMY_DATABASE_URI is set
    db_uri = f"postgresql://{settings.POSTGRES_USER}:{settings.POSTGRES_PASSWORD}@{server}:{port}/{settings.POSTGRES_DB}"
    logger.info(f"Using database URI: {db_uri}")

    engine = create_engine(
        db_uri,
        pool_pre_ping=True,
        echo=settings.ENVIRONMENT == "development",
    )
    logger.info("Successfully created database engine")

    # Create session factory
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
except Exception as e:
    logger.warning(f"Failed to create database engine: {e}")
    # Create a SQLite in-memory engine for testing
    logger.warning("Falling back to SQLite in-memory database (for testing only)")
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
    )

    # Create tables in SQLite memory database
    logger.info("Creating tables in SQLite memory database")
    Base.metadata.create_all(bind=engine)

    # Create session factory
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    """
    Get a database session.

    Yields:
        Database session.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
