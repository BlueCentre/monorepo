"""
Note schemas.
"""

from pydantic import BaseModel


class NoteBase(BaseModel):
    """
    Base Note schema.

    Attributes:
        title: Title of the note.
        content: Content of the note.
    """

    title: str
    content: str | None = None


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

    title: str | None = None


class NoteInDBBase(NoteBase):
    """
    Base Note in DB schema.

    Attributes:
        id: ID of the note.
        user_id: ID of the user who owns the note.
    """

    id: int
    user_id: int | None = None

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
