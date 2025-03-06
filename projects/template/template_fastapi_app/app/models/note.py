"""
Note model.
"""

from sqlalchemy import Column, String, Text, ForeignKey, Integer
from sqlalchemy.orm import relationship

from app.db.session import Base


class Note(Base):
    """
    Note model.
    
    Attributes:
        title: Title of the note.
        content: Content of the note.
        user_id: ID of the user who owns the note.
        user: User who owns the note.
    """
    
    title = Column(String(255), index=True, nullable=False)
    content = Column(Text, nullable=True)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=True)
    user = relationship("User", back_populates="notes") 