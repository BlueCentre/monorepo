"""
CRUD module initialization.
"""

from app.crud.crud_item import item
from app.crud.crud_user import user
from app.crud.note import note

__all__ = ["item", "user", "note"]
