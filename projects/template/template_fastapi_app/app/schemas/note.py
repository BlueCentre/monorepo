"""
Note schemas.
"""

from typing import Optional

from pydantic import BaseModel


class NoteBase(BaseModel):
    """
    Base Note schema.
    
    Attributes:
        title: Title of the note.
        content: Content of the note.
    """
    
    title: str
    content: Optional[str] = None


class NoteCreate(NoteBase):
    """
    Note creation schema.
    """
    
    pass


class NoteUpdate(NoteBase):
    """
    Note update schema.
    
    All fields are optional for updates.
    """
    
    title: Optional[str] = None


class NoteInDBBase(NoteBase):
    """
    Base Note in DB schema.
    
    Attributes:
        id: ID of the note.
        user_id: ID of the user who owns the note.
    """
    
    id: int
    user_id: Optional[int] = None
    
    class Config:
        orm_mode = True


class Note(NoteInDBBase):
    """
    Note schema.
    """
    
    pass


class NoteInDB(NoteInDBBase):
    """
    Note in DB schema.
    """
    
    pass 