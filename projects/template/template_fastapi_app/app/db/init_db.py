"""
Database initialization script.
"""

import logging
from sqlalchemy.orm import Session

from app import crud, schemas
from app.core.config import settings
from app.db import base  # noqa: F401

logger = logging.getLogger(__name__)


def init_db(db: Session) -> None:
    """
    Initialize the database with a superuser.
    
    Args:
        db: Database session.
    """
    # Create superuser if it doesn't exist
    user = crud.user.get_by_email(db, email=settings.FIRST_SUPERUSER_EMAIL)
    if not user:
        user_in = schemas.UserCreate(
            email=settings.FIRST_SUPERUSER_EMAIL,
            password=settings.FIRST_SUPERUSER_PASSWORD,
            full_name="Initial Superuser",
            is_superuser=True,
            is_active=True,
        )
        user = crud.user.create(db, obj_in=user_in)
        logger.info(f"Superuser created: {user.email}")
    else:
        logger.info(f"Superuser already exists: {user.email}")
    
    # Create sample items if they don't exist
    item = crud.item.get_by_title(db, title="Sample Item")
    if not item:
        item_in = schemas.ItemCreate(
            title="Sample Item",
            description="This is a sample item created during database initialization.",
            is_active=True,
        )
        item = crud.item.create_with_owner(db, obj_in=item_in, owner_id=user.id)
        logger.info(f"Sample item created: {item.title}")
    else:
        logger.info(f"Sample item already exists: {item.title}") 