"""
Database module initialization.
"""

# This file is intentionally left mostly empty to make the directory a Python package.
# This enables importing modules from this package.

# Import modules that should be available when importing from app.db
try:
    from app.db.base import Base  # noqa
    from app.db.session import SessionLocal  # noqa
except ImportError:
    # These imports may fail during early application bootstrap or in certain contexts
    pass
