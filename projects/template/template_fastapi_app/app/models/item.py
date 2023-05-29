"""
Item model.
"""

from sqlalchemy import Column, String, Text, Boolean, ForeignKey, Integer
from sqlalchemy.orm import relationship

from app.db.session import Base


class Item(Base):
    """
    Item model.
    
    Attributes:
        title: Title of the item.
        description: Description of the item.
        is_active: Whether the item is active.
        owner_id: ID of the user who owns the item.
        owner: User who owns the item.
    """
    
    title = Column(String(255), index=True, nullable=False)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    owner_id = Column(Integer, ForeignKey("user.id"), nullable=True)
    owner = relationship("User", back_populates="items") 