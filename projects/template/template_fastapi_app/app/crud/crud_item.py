"""
CRUD operations for Item model.
"""

from typing import List, Optional

from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.item import Item
from app.schemas.item import ItemCreate, ItemUpdate


class CRUDItem(CRUDBase[Item, ItemCreate, ItemUpdate]):
    """CRUD operations for Item model."""
    
    def create_with_owner(
        self, db: Session, *, obj_in: ItemCreate, owner_id: int
    ) -> Item:
        """
        Create a new item with owner.
        
        Args:
            db: Database session.
            obj_in: Input data.
            owner_id: ID of the owner.
            
        Returns:
            The created item.
        """
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = Item(**obj_in_data, owner_id=owner_id)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def get_multi_by_owner(
        self, db: Session, *, owner_id: int, skip: int = 0, limit: int = 100
    ) -> List[Item]:
        """
        Get multiple items by owner.
        
        Args:
            db: Database session.
            owner_id: ID of the owner.
            skip: Number of records to skip.
            limit: Maximum number of records to return.
            
        Returns:
            List of items.
        """
        return (
            db.query(self.model)
            .filter(Item.owner_id == owner_id)
            .offset(skip)
            .limit(limit)
            .all()
        )
    
    def get_by_title(self, db: Session, *, title: str) -> Optional[Item]:
        """
        Get an item by title.
        
        Args:
            db: Database session.
            title: Title of the item.
            
        Returns:
            The item if found, None otherwise.
        """
        return db.query(Item).filter(Item.title == title).first()


item = CRUDItem(Item) 