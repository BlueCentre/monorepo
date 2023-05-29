"""
User model.
"""

from sqlalchemy import Column, String, Boolean
from sqlalchemy.orm import relationship

from app.db.session import Base


class User(Base):
    """
    User model.
    
    Attributes:
        email: Email address of the user.
        hashed_password: Hashed password of the user.
        full_name: Full name of the user.
        is_active: Whether the user is active.
        is_superuser: Whether the user is a superuser.
        items: Items owned by the user.
        notes: Notes owned by the user.
    """
    
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=True)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    items = relationship("Item", back_populates="owner")
    notes = relationship("Note", back_populates="user") 