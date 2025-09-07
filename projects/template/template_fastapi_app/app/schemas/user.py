"""
User schemas.
"""

from pydantic import BaseModel, EmailStr

from app.schemas.item import Item


# Shared properties
class UserBase(BaseModel):
    """
    Base schema for User.

    Attributes:
        email: Email address of the user.
        is_active: Whether the user is active.
        is_superuser: Whether the user is a superuser.
        full_name: Full name of the user.
    """

    email: EmailStr | None = None
    is_active: bool | None = True
    is_superuser: bool = False
    full_name: str | None = None


# Properties to receive via API on creation
class UserCreate(UserBase):
    """
    Schema for creating a User.

    Attributes:
        email: Email address of the user.
        password: Password of the user.
    """

    email: EmailStr
    password: str


# Properties to receive via API on update
class UserUpdate(UserBase):
    """
    Schema for updating a User.

    Attributes:
        password: Password of the user.
    """

    password: str | None = None


# Properties shared by models stored in DB
class UserInDBBase(UserBase):
    """
    Base schema for User in DB.

    Attributes:
        id: ID of the user.
    """

    id: int | None = None

    class Config:
        """Pydantic configuration."""

        from_attributes = True


# Properties to return to client
class User(UserInDBBase):
    """Schema for returning a User to the client."""

    pass


# Properties stored in DB
class UserInDB(UserInDBBase):
    """
    Schema for User stored in DB.

    Attributes:
        hashed_password: Hashed password of the user.
    """

    hashed_password: str


# Additional properties to return via API
class UserWithItems(User):
    """
    Schema for returning a User with their items.

    Attributes:
        items: Items owned by the user.
    """

    items: list[Item] = []
