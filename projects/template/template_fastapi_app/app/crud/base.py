"""
Base CRUD class for database operations.
"""

from typing import Any, Generic, TypeVar

from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.db.base_class import Base

ModelType = TypeVar("ModelType", bound=Base)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)


class CRUDBase(Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    """
    Base class for CRUD operations.

    Attributes:
        model: The SQLAlchemy model class.
    """

    def __init__(self, model: type[ModelType]):
        """
        Initialize with SQLAlchemy model.

        Args:
            model: The SQLAlchemy model class.
        """
        self.model = model

    def get(self, db: Session, id: Any) -> ModelType | None:
        """
        Get a record by ID.

        Args:
            db: Database session.
            id: ID of the record.

        Returns:
            The record if found, None otherwise.
        """
        return db.query(self.model).filter(self.model.id == id).first()

    def get_multi(
        self, db: Session, *, skip: int = 0, limit: int = 100
    ) -> list[ModelType]:
        """
        Get multiple records.

        Args:
            db: Database session.
            skip: Number of records to skip.
            limit: Maximum number of records to return.

        Returns:
            List of records.
        """
        return db.query(self.model).offset(skip).limit(limit).all()

    def create(self, db: Session, *, obj_in: CreateSchemaType) -> ModelType:
        """
        Create a new record.

        Args:
            db: Database session.
            obj_in: Input data.

        Returns:
            The created record.
        """
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.model(**obj_in_data)  # type: ignore
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def update(
        self,
        db: Session,
        *,
        db_obj: ModelType,
        obj_in: UpdateSchemaType | dict[str, Any],
    ) -> ModelType:
        """
        Update a record.

        Args:
            db: Database session.
            db_obj: Database object to update.
            obj_in: Input data.

        Returns:
            The updated record.
        """
        obj_data = jsonable_encoder(db_obj)
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)
        for field in obj_data:
            if field in update_data:
                setattr(db_obj, field, update_data[field])
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def remove(self, db: Session, *, id: Any) -> ModelType:
        """
        Remove a record.

        Args:
            db: Database session.
            id: ID of the record.

        Returns:
            The removed record.
        """
        obj = db.query(self.model).get(id)
        db.delete(obj)
        db.commit()
        return obj
