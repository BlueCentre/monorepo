"""
CRUD operations for User model.
"""

from typing import Any, Dict, Optional, Union

from sqlalchemy.orm import Session

from app.core.security import get_password_hash, verify_password
from app.crud.base import CRUDBase
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate


class CRUDUser(CRUDBase[User, UserCreate, UserUpdate]):
    """CRUD operations for User model."""
    
    def get_by_email(self, db: Session, *, email: str) -> Optional[User]:
        """
        Get a user by email.
        
        Args:
            db: Database session.
            email: Email of the user.
            
        Returns:
            The user if found, None otherwise.
        """
        return db.query(User).filter(User.email == email).first()
    
    def create(self, db: Session, *, obj_in: UserCreate) -> User:
        """
        Create a new user.
        
        Args:
            db: Database session.
            obj_in: Input data.
            
        Returns:
            The created user.
        """
        db_obj = User(
            email=obj_in.email,
            hashed_password=get_password_hash(obj_in.password),
            full_name=obj_in.full_name,
            is_active=obj_in.is_active,
            is_superuser=obj_in.is_superuser,
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def update(
        self, db: Session, *, db_obj: User, obj_in: Union[UserUpdate, Dict[str, Any]]
    ) -> User:
        """
        Update a user.
        
        Args:
            db: Database session.
            db_obj: Database object to update.
            obj_in: Input data.
            
        Returns:
            The updated user.
        """
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)
        if update_data.get("password"):
            hashed_password = get_password_hash(update_data["password"])
            del update_data["password"]
            update_data["hashed_password"] = hashed_password
        return super().update(db, db_obj=db_obj, obj_in=update_data)
    
    def authenticate(self, db: Session, *, email: str, password: str) -> Optional[User]:
        """
        Authenticate a user.
        
        Args:
            db: Database session.
            email: Email of the user.
            password: Password of the user.
            
        Returns:
            The authenticated user if successful, None otherwise.
        """
        user = self.get_by_email(db, email=email)
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user
    
    def is_active(self, user: User) -> bool:
        """
        Check if a user is active.
        
        Args:
            user: The user to check.
            
        Returns:
            True if the user is active, False otherwise.
        """
        return user.is_active
    
    def is_superuser(self, user: User) -> bool:
        """
        Check if a user is a superuser.
        
        Args:
            user: The user to check.
            
        Returns:
            True if the user is a superuser, False otherwise.
        """
        return user.is_superuser


user = CRUDUser(User) 