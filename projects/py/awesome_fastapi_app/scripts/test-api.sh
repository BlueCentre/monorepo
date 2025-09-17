#!/bin/bash
set -e

echo "Running API verification tests..."
cd /app/src

# Initialize the database first
echo "Running database initialization..."
python -c "
from app.db.session import SessionLocal, engine
from app.db.base import Base
from app.core.config import settings
import app.crud as crud
import app.schemas as schemas
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('db_init')

print('Creating database tables...')
Base.metadata.create_all(bind=engine)

print('Initializing database with default superuser...')
db = SessionLocal()

try:
    user = crud.user.get_by_email(db, email=settings.FIRST_SUPERUSER)
    if not user:
        logger.info('Creating superuser...')
        user_in = schemas.UserCreate(
            email=settings.FIRST_SUPERUSER,
            password=settings.FIRST_SUPERUSER_PASSWORD,
            full_name='Initial Superuser',
            is_superuser=True,
            is_active=True
        )
        user = crud.user.create(db, obj_in=user_in)
        logger.info(f'Superuser created: {user.email}')
    else:
        logger.info(f'Superuser already exists: {user.email}')
    
    # Create sample item if it doesn't exist
    item = crud.item.get_by_title(db, title='Sample Item')
    if not item:
        logger.info('Creating sample item...')
        item_in = schemas.ItemCreate(
            title='Sample Item',
            description='This is a sample item created during database initialization.',
            is_active=True
        )
        item = crud.item.create_with_owner(db, obj_in=item_in, owner_id=user.id)
        logger.info(f'Sample item created: {item.title}')
    else:
        logger.info(f'Sample item already exists: {item.title}')
    
    logger.info('Database initialization completed successfully!')
except Exception as e:
    logger.error(f'Error during database initialization: {e}')
    exit(1)
finally:
    db.close()
"

echo "Database initialization completed successfully!"

# Run the smoke test
echo "Running smoke tests..."

# Test the health endpoint
echo "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:80/health)
echo "Health response: $HEALTH_RESPONSE"

if ! echo "$HEALTH_RESPONSE" | grep -q "ok"; then
  echo "Health check failed!"
  exit 1
fi

echo "Health check passed!"

# Test login endpoint
echo "Testing login endpoint..."
LOGIN_RESPONSE=$(curl -s -X 'POST' 'http://localhost:80/api/v1/login/access-token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'username=admin@example.com&password=admin')
echo "Login response: $LOGIN_RESPONSE"

if ! echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
  echo "Login test failed - could not get authentication token!"
  exit 1
fi

echo "Login successful, authentication token received!"

# Extract the token
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

# Test users endpoint
echo "Testing users endpoint..."
USERS_RESPONSE=$(curl -s -X 'GET' 'http://localhost:80/api/v1/users/' \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $TOKEN")
echo "Users response: $USERS_RESPONSE"

if ! echo "$USERS_RESPONSE" | grep -q "admin@example.com"; then
  echo "Users endpoint test failed!"
  exit 1
fi

echo "Users endpoint test passed!"
echo "API verification successful! All tests passed."

# All tests passed
exit 0 