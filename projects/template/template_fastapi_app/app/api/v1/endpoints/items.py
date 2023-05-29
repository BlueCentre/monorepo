"""
Items endpoints for item management.
"""

from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps
from app.pubsub.publisher import pubsub_publisher

router = APIRouter()


@router.get("/", response_model=List[schemas.Item])
def read_items(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve items.
    
    Args:
        db: Database session.
        skip: Number of items to skip.
        limit: Maximum number of items to return.
        current_user: Current user.
        
    Returns:
        List of items.
    """
    if crud.user.is_superuser(current_user):
        items = crud.item.get_multi(db, skip=skip, limit=limit)
    else:
        items = crud.item.get_multi_by_owner(
            db=db, owner_id=current_user.id, skip=skip, limit=limit
        )
    return items


@router.post("/", response_model=schemas.Item)
def create_item(
    *,
    db: Session = Depends(deps.get_db),
    item_in: schemas.ItemCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new item.
    
    Args:
        db: Database session.
        item_in: Item data.
        current_user: Current user.
        
    Returns:
        Created item.
    """
    item = crud.item.create_with_owner(db=db, obj_in=item_in, owner_id=current_user.id)
    
    # Publish message to PubSub
    try:
        pubsub_publisher.publish_message(
            "example",
            {
                "action": "item_created",
                "item_id": item.id,
                "owner_id": current_user.id,
            },
            {"user_id": str(current_user.id)}
        )
    except Exception as e:
        # Log error but don't fail the request
        print(f"Error publishing message: {e}")
    
    return item


@router.put("/{id}", response_model=schemas.Item)
def update_item(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    item_in: schemas.ItemUpdate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update an item.
    
    Args:
        db: Database session.
        id: Item ID.
        item_in: Item data.
        current_user: Current user.
        
    Returns:
        Updated item.
    """
    item = crud.item.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    if not crud.user.is_superuser(current_user) and (item.owner_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    item = crud.item.update(db=db, db_obj=item, obj_in=item_in)
    return item


@router.get("/{id}", response_model=schemas.Item)
def read_item(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get item by ID.
    
    Args:
        db: Database session.
        id: Item ID.
        current_user: Current user.
        
    Returns:
        Item.
    """
    item = crud.item.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    if not crud.user.is_superuser(current_user) and (item.owner_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    return item


@router.delete("/{id}", response_model=schemas.Item)
def delete_item(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete an item.
    
    Args:
        db: Database session.
        id: Item ID.
        current_user: Current user.
        
    Returns:
        Deleted item.
    """
    item = crud.item.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    if not crud.user.is_superuser(current_user) and (item.owner_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    item = crud.item.remove(db=db, id=id)
    return item 