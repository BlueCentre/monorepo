"""
Configuration settings for the FastAPI application.
"""

import logging
import os
import secrets
from typing import Any

try:
    # Try to import from Pydantic v2
    from pydantic import (
        AnyHttpUrl,
        ConfigDict,
        EmailStr,
        PostgresDsn,
        field_validator,
    )
    from pydantic_settings import BaseSettings

    IS_PYDANTIC_V2 = True
except ImportError:
    # Fall back to Pydantic v1
    from pydantic import (
        AnyHttpUrl,
        BaseSettings,
        EmailStr,
        PostgresDsn,
        validator,
    )

    IS_PYDANTIC_V2 = False

logger = logging.getLogger(__name__)

# TODO: Get config from configmap if environment does not exist
class Settings(BaseSettings):
    """Application settings."""

    # Base settings
    PROJECT_NAME: str = os.getenv("PROJECT_NAME", "Template FastAPI App")
    APP_NAME: str = os.getenv("PROJECT_NAME", "Template FastAPI App")
    API_V1_STR: str = os.getenv("API_V1_STR", "/api/v1")

    # Secret key for JWT token generation - fallback value for backwards compatibility
    # The actual key will be managed by the secret_rotation module when available
    SECRET_KEY: str = os.getenv("SECRET_KEY", secrets.token_urlsafe(32))

    # Secret rotation settings
    SECRET_ROTATION_ENABLED: bool = (
        os.getenv("SECRET_ROTATION_ENABLED", "True").lower() == "true"
    )
    SECRET_KEY_LIFETIME_DAYS: int = int(os.getenv("SECRET_KEY_LIFETIME_DAYS", "30"))
    SECRET_KEY_TRANSITION_DAYS: int = int(os.getenv("SECRET_KEY_TRANSITION_DAYS", "1"))

    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days

    # CORS settings
    BACKEND_CORS_ORIGINS: list[AnyHttpUrl] = []

    # Define validator based on Pydantic version
    if IS_PYDANTIC_V2:

        @classmethod
        @field_validator("BACKEND_CORS_ORIGINS", mode="before")
        def assemble_cors_origins(cls, v: str | list[str]) -> list[str] | str:
            """Validate CORS origins."""
            if isinstance(v, str) and not v.startswith("["):
                return [i.strip() for i in v.split(",")]
            elif isinstance(v, (list, str)):
                return v
            raise ValueError(v)
    else:

        @validator("BACKEND_CORS_ORIGINS", pre=True, allow_reuse=True)
        def assemble_cors_origins(cls, v: str | list[str]) -> list[str] | str:
            """Validate CORS origins."""
            if isinstance(v, str) and not v.startswith("["):
                return [i.strip() for i in v.split(",")]
            elif isinstance(v, (list, str)):
                return v
            raise ValueError(v)

    # Project directories
    PROJECT_ROOT: str = os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    )

    # Database settings
    POSTGRES_SERVER: str = os.getenv("POSTGRES_SERVER", "localhost")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "postgres")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "app")
    SQLALCHEMY_DATABASE_URI: PostgresDsn | None = None

    # Define validator based on Pydantic version
    if IS_PYDANTIC_V2:

        @classmethod
        @field_validator("SQLALCHEMY_DATABASE_URI", mode="before")
        def assemble_db_connection(cls, v: str | None, values: dict[str, Any]) -> Any:
            """Create SQLAlchemy database URI from environment variables."""
            if isinstance(v, str):
                logger.info(f"Using existing database URI: {v}")
                return v

            # In Pydantic v2, we access values directly
            postgres_server = values.get("POSTGRES_SERVER", "")
            logger.info(f"Original POSTGRES_SERVER: {postgres_server}")

            if postgres_server.startswith("tcp://"):
                postgres_server = postgres_server.split(":")[-2].replace("//", "")
                logger.info(f"Modified POSTGRES_SERVER: {postgres_server}")

            # Handle case where POSTGRES_PORT might be a full TCP URL
            postgres_port_str = values.get("POSTGRES_PORT", "5432")
            logger.info(f"Original POSTGRES_PORT: {postgres_port_str}")

            if postgres_port_str.startswith("tcp://"):
                # Extract just the port number from the TCP URL
                postgres_port_str = postgres_port_str.split(":")[-1]
                logger.info(f"Modified POSTGRES_PORT: {postgres_port_str}")

            try:
                postgres_port = int(postgres_port_str)
            except (ValueError, TypeError):
                logger.warning(
                    f"Could not convert port '{postgres_port_str}' to int, using default 5432"
                )
                postgres_port = 5432

            # Ensure we have valid values
            postgres_user = values.get("POSTGRES_USER", "postgres")
            postgres_password = values.get("POSTGRES_PASSWORD", "postgres")
            postgres_db = values.get("POSTGRES_DB", "app")

            logger.info(f"POSTGRES_USER: {postgres_user}")
            logger.info(
                f"POSTGRES_PASSWORD: {'*' * len(postgres_password) if postgres_password else 'None'}"
            )
            logger.info(f"POSTGRES_DB: {postgres_db}")

            if not postgres_server or postgres_server == "None":
                logger.info("Setting POSTGRES_SERVER to default 'postgres'")
                postgres_server = "postgres"

            # Build and return the database URI
            try:
                db_uri = PostgresDsn.build(
                    scheme="postgresql",
                    username=postgres_user,
                    password=postgres_password,
                    host=postgres_server,
                    port=postgres_port,
                    path=f"/{postgres_db}",
                )
                logger.info(f"Built PostgreSQL DSN: {db_uri}")
                return db_uri
            except Exception as e:
                logger.error(f"Error building PostgreSQL DSN: {e}")
                # Return a fallback connection string
                fallback_uri = f"postgresql://{postgres_user}:{postgres_password}@{postgres_server}:{postgres_port}/{postgres_db}"
                logger.info(f"Using fallback connection string: {fallback_uri}")
                return fallback_uri
    else:

        @validator("SQLALCHEMY_DATABASE_URI", pre=True, allow_reuse=True)
        def assemble_db_connection(cls, v: str | None, values: dict[str, Any]) -> Any:
            """Create SQLAlchemy database URI from environment variables."""
            if isinstance(v, str):
                logger.info(f"Using existing database URI: {v}")
                return v

            # In Pydantic v1, we might need to access values through values.data
            postgres_server = values.get("POSTGRES_SERVER", "")
            logger.info(f"Original POSTGRES_SERVER: {postgres_server}")

            if postgres_server.startswith("tcp://"):
                postgres_server = postgres_server.split(":")[-2].replace("//", "")
                logger.info(f"Modified POSTGRES_SERVER: {postgres_server}")

            # Handle case where POSTGRES_PORT might be a full TCP URL
            postgres_port_str = values.get("POSTGRES_PORT", "5432")
            logger.info(f"Original POSTGRES_PORT: {postgres_port_str}")

            if postgres_port_str.startswith("tcp://"):
                # Extract just the port number from the TCP URL
                postgres_port_str = postgres_port_str.split(":")[-1]
                logger.info(f"Modified POSTGRES_PORT: {postgres_port_str}")

            try:
                postgres_port = int(postgres_port_str)
            except (ValueError, TypeError):
                logger.warning(
                    f"Could not convert port '{postgres_port_str}' to int, using default 5432"
                )
                postgres_port = 5432

            # Ensure we have valid values
            postgres_user = values.get("POSTGRES_USER", "postgres")
            postgres_password = values.get("POSTGRES_PASSWORD", "postgres")
            postgres_db = values.get("POSTGRES_DB", "app")

            logger.info(f"POSTGRES_USER: {postgres_user}")
            logger.info(
                f"POSTGRES_PASSWORD: {'*' * len(postgres_password) if postgres_password else 'None'}"
            )
            logger.info(f"POSTGRES_DB: {postgres_db}")

            if not postgres_server or postgres_server == "None":
                logger.info("Setting POSTGRES_SERVER to default 'postgres'")
                postgres_server = "postgres"

            # Build and return the database URI
            try:
                db_uri = PostgresDsn.build(
                    scheme="postgresql",
                    username=postgres_user,
                    password=postgres_password,
                    host=postgres_server,
                    port=postgres_port,
                    path=f"/{postgres_db}",
                )
                logger.info(f"Built PostgreSQL DSN: {db_uri}")
                return db_uri
            except Exception as e:
                logger.error(f"Error building PostgreSQL DSN: {e}")
                # Return a fallback connection string
                fallback_uri = f"postgresql://{postgres_user}:{postgres_password}@{postgres_server}:{postgres_port}/{postgres_db}"
                logger.info(f"Using fallback connection string: {fallback_uri}")
                return fallback_uri

    # Google Cloud PubSub settings
    GCP_PROJECT_ID: str = os.getenv("GCP_PROJECT_ID", "")
    PUBSUB_EMULATOR_HOST: str | None = os.getenv("PUBSUB_EMULATOR_HOST")

    # Topic and subscription names
    PUBSUB_TOPIC_EXAMPLE: str = os.getenv("PUBSUB_TOPIC_EXAMPLE", "example-topic")
    PUBSUB_SUBSCRIPTION_EXAMPLE: str = os.getenv(
        "PUBSUB_SUBSCRIPTION_EXAMPLE", "example-subscription"
    )

    # Authentication
    FIRST_SUPERUSER: EmailStr = os.getenv("FIRST_SUPERUSER", "admin@example.com")
    FIRST_SUPERUSER_PASSWORD: str = os.getenv("FIRST_SUPERUSER_PASSWORD", "admin")
    USERS_OPEN_REGISTRATION: bool = (
        os.getenv("USERS_OPEN_REGISTRATION", "False").lower() == "true"
    )

    # Environment name
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")

    # OpenTelemetry settings
    ENABLE_TELEMETRY: bool = os.getenv("ENABLE_TELEMETRY", "True").lower() == "true"
    OTLP_EXPORTER_ENDPOINT: str | None = os.getenv("OTLP_EXPORTER_ENDPOINT")
    OTLP_SERVICE_NAME: str | None = os.getenv("OTLP_SERVICE_NAME")

    # Server settings
    PORT: int = int(os.getenv("PORT", "8000"))
    RELOAD: bool = os.getenv("RELOAD", "True").lower() == "true"

    # Algorithm for token generation
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")

    # Configure settings based on Pydantic version
    if IS_PYDANTIC_V2:
        model_config = ConfigDict(
            case_sensitive=True,
            env_file=".env",
        )
    else:

        class Config:
            """Pydantic config."""

            case_sensitive = True
            env_file = ".env"


settings = Settings()
