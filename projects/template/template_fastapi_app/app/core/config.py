"""
Configuration settings for the FastAPI application.
"""

import os
import secrets
from typing import Any, Dict, List, Optional, Union

from pydantic import (
    AnyHttpUrl,
    EmailStr,
    PostgresDsn,
    field_validator,
    ConfigDict,
)
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""
    
    # Base settings
    PROJECT_NAME: str = "Template FastAPI App"
    APP_NAME: str = "Template FastAPI App"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = secrets.token_urlsafe(32)
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days
    
    # CORS settings
    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = []

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        """Validate CORS origins."""
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    # Project directories
    PROJECT_ROOT: str = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    
    # Database settings
    POSTGRES_SERVER: str = os.getenv("POSTGRES_SERVER", "localhost")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "postgres")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "app")
    SQLALCHEMY_DATABASE_URI: Optional[PostgresDsn] = None

    @field_validator("SQLALCHEMY_DATABASE_URI", mode="before")
    def assemble_db_connection(cls, v: Optional[str], values: Dict[str, Any]) -> Any:
        """Create SQLAlchemy database URI from environment variables."""
        if isinstance(v, str):
            return v
        
        # Handle the case where POSTGRES_SERVER might be a service URL
        postgres_server = values.data.get("POSTGRES_SERVER", "")
        if postgres_server.startswith("tcp://"):
            postgres_server = postgres_server.replace("tcp://", "")
        
        # Handle the case where POSTGRES_PORT might not be a valid integer
        try:
            postgres_port = int(values.data.get("POSTGRES_PORT", "5432"))
        except (ValueError, TypeError):
            postgres_port = 5432
        
        return PostgresDsn.build(
            scheme="postgresql",
            username=values.data.get("POSTGRES_USER"),
            password=values.data.get("POSTGRES_PASSWORD"),
            host=postgres_server,
            port=postgres_port,
            path=f"{values.data.get('POSTGRES_DB') or ''}",
        )

    # Google Cloud PubSub settings
    GCP_PROJECT_ID: str = os.getenv("GCP_PROJECT_ID", "")
    PUBSUB_EMULATOR_HOST: Optional[str] = os.getenv("PUBSUB_EMULATOR_HOST")
    
    # Topic and subscription names
    PUBSUB_TOPIC_EXAMPLE: str = os.getenv("PUBSUB_TOPIC_EXAMPLE", "example-topic")
    PUBSUB_SUBSCRIPTION_EXAMPLE: str = os.getenv("PUBSUB_SUBSCRIPTION_EXAMPLE", "example-subscription")
    
    # Authentication
    FIRST_SUPERUSER: EmailStr = os.getenv("FIRST_SUPERUSER", "admin@example.com")
    FIRST_SUPERUSER_PASSWORD: str = os.getenv("FIRST_SUPERUSER_PASSWORD", "admin")
    USERS_OPEN_REGISTRATION: bool = os.getenv("USERS_OPEN_REGISTRATION", "False").lower() == "true"

    # Environment name
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    
    # OpenTelemetry settings
    ENABLE_TELEMETRY: bool = os.getenv("ENABLE_TELEMETRY", "True").lower() == "true"
    OTLP_EXPORTER_ENDPOINT: Optional[str] = os.getenv("OTLP_EXPORTER_ENDPOINT")
    OTLP_SERVICE_NAME: Optional[str] = os.getenv("OTLP_SERVICE_NAME")
    
    # Server settings
    PORT: int = int(os.getenv("PORT", "8000"))
    RELOAD: bool = os.getenv("RELOAD", "True").lower() == "true"
    
    # Algorithm for token generation
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    
    # Pydantic configuration
    model_config = ConfigDict(
        case_sensitive=True,
        env_file=".env",
    )


settings = Settings() 