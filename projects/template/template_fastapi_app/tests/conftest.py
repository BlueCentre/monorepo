"""
Test fixtures for pytest.

This module contains fixtures that can be shared across multiple test files.
"""

import asyncio
import os
from typing import AsyncGenerator, Generator, Dict, Any

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, event
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool

from app.api.deps import get_db
from app.db.session import Base
from app.main import app as main_app
from app.core.config import settings


# In-memory SQLite database for testing
TEST_SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

# Create engine and tables for testing
engine = create_engine(
    TEST_SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

# Enable foreign keys in SQLite
@event.listens_for(engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):
    """Enable foreign keys in SQLite."""
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create async engine for async tests
try:
    # Only import if needed to avoid dependency issues
    import aiosqlite
    async_engine = create_async_engine(
        "sqlite+aiosqlite:///./test.db",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    AsyncTestingSessionLocal = sessionmaker(
        autocommit=False, 
        autoflush=False, 
        bind=async_engine, 
        class_=AsyncSession
    )
except ImportError:
    # Fallback if aiosqlite is not installed
    async_engine = None
    AsyncTestingSessionLocal = None


@pytest.fixture(scope="session", autouse=True)
def create_test_db():
    """Create test database tables."""
    # SQLite specific adjustments: Create all tables from scratch for each test session
    if os.path.exists("./test.db"):
        os.remove("./test.db")
    
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)
    
    # Clean up the test database file
    if os.path.exists("./test.db"):
        os.remove("./test.db")


@pytest.fixture
def db() -> Generator[Session, None, None]:
    """Get a SQLAlchemy session for the test database."""
    connection = engine.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()


@pytest.fixture
async def async_db() -> AsyncGenerator[AsyncSession, None]:
    """Get an async SQLAlchemy session for the test database."""
    if AsyncTestingSessionLocal is None:
        pytest.skip("aiosqlite not installed, skipping async tests")
        return
        
    async with AsyncTestingSessionLocal() as session:
        # Start a nested transaction
        async with session.begin():
            # Use session
            yield session
            # Rollback the nested transaction
            await session.rollback()


@pytest.fixture
def client(db) -> Generator[TestClient, None, None]:
    """Get a FastAPI test client with DB session override."""
    
    def override_get_db():
        try:
            yield db
        finally:
            pass
    
    main_app.dependency_overrides[get_db] = override_get_db
    with TestClient(main_app) as test_client:
        yield test_client
    main_app.dependency_overrides.clear()


@pytest.fixture
def app() -> FastAPI:
    """Get the FastAPI application."""
    return main_app


@pytest.fixture
def test_settings() -> Dict[str, Any]:
    """Get test settings."""
    return {
        "ENVIRONMENT": "test",
        "DEBUG": True,
        "DB_CONNECTION": TEST_SQLALCHEMY_DATABASE_URL,
        "API_V1_STR": "/api/v1",
        "PROJECT_NAME": "FastAPI Test Project",
        "FIRST_SUPERUSER": "admin@example.com",
        "FIRST_SUPERUSER_PASSWORD": "admin",
        "USERS_OPEN_REGISTRATION": True
    }


@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for async tests."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close() 