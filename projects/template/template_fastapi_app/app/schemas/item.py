"""
Item schemas.
"""

from pydantic import BaseModel


# Shared properties
class ItemBase(BaseModel):
    """
    Base schema for Item.

    Attributes:
        title: Title of the item.
        description: Description of the item.
    """

    title: str
    description: str | None = None


# Properties to receive on item creation
class ItemCreate(ItemBase):
    """Schema for creating an Item."""

    pass


# Properties to receive on item update
class ItemUpdate(ItemBase):
    """
    Schema for updating an Item.

    All attributes are optional to allow partial updates.
    """

    title: str | None = None
    description: str | None = None
    is_active: bool | None = None


# Properties shared by models stored in DB
class ItemInDBBase(ItemBase):
    """
    Base schema for Item in DB.

    Attributes:
        id: ID of the item.
        is_active: Whether the item is active.
        owner_id: ID of the user who owns the item.
    """

    id: int
    is_active: bool
    owner_id: int | None = None

    class Config:
        """Pydantic configuration."""

        from_attributes = True


# Properties to return to client
class Item(ItemInDBBase):
    """Schema for returning an Item to the client."""

    pass


# Properties stored in DB
class ItemInDB(ItemInDBBase):
    """Schema for Item stored in DB."""

    pass
