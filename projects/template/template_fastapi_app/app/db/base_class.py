"""
Base class for SQLAlchemy models.
"""

import re
from typing import Any

from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy import Column, Integer, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    """Base class for SQLAlchemy models."""
    
    # Generate __tablename__ automatically
    @declared_attr.directive
    @classmethod
    def __tablename__(cls) -> str:
        """
        Generate table name from class name.
        
        Returns:
            str: Table name.
        """
        # Convert CamelCase to snake_case
        name = re.sub('(?<!^)(?=[A-Z])', '_', cls.__name__).lower()
        return name
    
    # Common columns
    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False) 