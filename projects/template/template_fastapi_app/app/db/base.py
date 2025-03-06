"""
Import all models here to ensure they are registered with SQLAlchemy.
"""

from app.db.base_class import Base  # noqa
from app.models.user import User  # noqa
from app.models.item import Item  # noqa 