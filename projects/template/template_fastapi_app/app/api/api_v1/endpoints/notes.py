"""
Notes API endpoints.
"""

from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps

router = APIRouter()


@router.get("/", response_model=List[schemas.Note])
def read_notes(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve notes.
    """
    if crud.user.is_superuser(current_user):
        notes = crud.note.get_multi(db, skip=skip, limit=limit)
    else:
        notes = crud.note.get_multi_by_owner(
            db=db, owner_id=current_user.id, skip=skip, limit=limit
        )
    return notes


@router.post("/", response_model=schemas.Note)
def create_note(
    *,
    db: Session = Depends(deps.get_db),
    note_in: schemas.NoteCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new note.
    """
    note = crud.note.create_with_owner(db=db, obj_in=note_in, owner_id=current_user.id)
    return note


@router.get("/{id}", response_model=schemas.Note)
def read_note(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get note by ID.
    """
    note = crud.note.get(db=db, id=id)
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    if not crud.user.is_superuser(current_user) and (note.user_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    return note


@router.put("/{id}", response_model=schemas.Note)
def update_note(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    note_in: schemas.NoteUpdate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update a note.
    """
    note = crud.note.get(db=db, id=id)
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    if not crud.user.is_superuser(current_user) and (note.user_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    note = crud.note.update(db=db, db_obj=note, obj_in=note_in)
    return note


@router.delete("/{id}", response_model=schemas.Note)
def delete_note(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete a note.
    """
    note = crud.note.get(db=db, id=id)
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    if not crud.user.is_superuser(current_user) and (note.user_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    note = crud.note.remove(db=db, id=id)
    return note 