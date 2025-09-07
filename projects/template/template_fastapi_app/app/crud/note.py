"""
CRUD operations for notes.
"""

from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.note import Note
from app.schemas.note import NoteCreate, NoteUpdate


class CRUDNote(CRUDBase[Note, NoteCreate, NoteUpdate]):
    """
    CRUD operations for notes.
    """

    def create_with_owner(
        self, db: Session, *, obj_in: NoteCreate, owner_id: int
    ) -> Note:
        """
        Create a new note with an owner.

        Args:
            db: Database session.
            obj_in: Note creation data.
            owner_id: ID of the owner.

        Returns:
            The created note.
        """

        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.model(**obj_in_data, user_id=owner_id)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_multi_by_owner(
        self, db: Session, *, owner_id: int, skip: int = 0, limit: int = 100
    ) -> list[Note]:
        """
        Get multiple notes by owner.

        Args:
            db: Database session.
            owner_id: ID of the owner.
            skip: Number of notes to skip.
            limit: Maximum number of notes to return.

        Returns:
            List of notes.
        """

        return (
            db.query(self.model)
            .filter(Note.user_id == owner_id)
            .offset(skip)
            .limit(limit)
            .all()
        )


note = CRUDNote(Note)
