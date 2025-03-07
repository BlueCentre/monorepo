#!/bin/bash
set -e

echo "Starting API verification..."

# Wait for the application to be ready
echo "Waiting for application to be ready..."
sleep 10

# Get the pod name
POD_NAME=$(kubectl get pods -n template-fastapi-app -l app=template-fastapi-app,component!=db-init -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
  echo "Failed to find application pod!"
  exit 1
fi

echo "Found pod: $POD_NAME"

# Create a helper script to run in the application pod
cat > /tmp/verify-script.py << 'EOF'
#!/usr/bin/env python3
import requests
import json
import sys
import os

print("Running API tests...")

# Initialize the database first (if needed)
print("Initializing database...")
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
    sys.exit(1)
finally:
    db.close()

print("Database initialization completed successfully!")

# Determine the API URL
# Try multiple possibilities
api_urls = [
    "http://localhost:80/",
    "http://localhost:8000/",
    "http://127.0.0.1:8000/",
    "http://127.0.0.1:80/"
]

working_api_url = None

for base_url in api_urls:
    try:
        print(f"Trying API URL: {base_url}")
        response = requests.get(f"{base_url}health", timeout=2)
        if response.status_code == 200:
            working_api_url = base_url
            print(f"Found working API URL: {working_api_url}")
            break
    except Exception as e:
        print(f"URL {base_url} failed: {e}")

if not working_api_url:
    print("Could not find a working API URL!")
    sys.exit(1)

# Test health endpoint
print("Testing health endpoint...")
try:
    health_response = requests.get(f"{working_api_url}health")
    print(f"Health response: {health_response.text}")
    
    if "ok" not in health_response.text:
        print("Health check failed!")
        sys.exit(1)
    
    print("Health check passed!")
except Exception as e:
    print(f"Health check failed with error: {e}")
    sys.exit(1)

# Test login endpoint
print("Testing login endpoint...")
try:
    login_data = {
        "username": "admin@example.com",
        "password": "admin"
    }
    login_response = requests.post(
        f"{working_api_url}api/v1/login/access-token",
        data=login_data,
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )
    print(f"Login response: {login_response.text}")
    
    login_json = login_response.json()
    if "access_token" not in login_json:
        print("Login test failed - could not get authentication token!")
        sys.exit(1)
    
    print("Login successful, authentication token received!")
    
    # Extract the token
    token = login_json["access_token"]
    
    # Test users endpoint
    print("Testing users endpoint...")
    users_response = requests.get(
        f"{working_api_url}api/v1/users/",
        headers={
            "accept": "application/json",
            "Authorization": f"Bearer {token}"
        }
    )
    print(f"Users response: {users_response.text}")
    
    if "admin@example.com" not in users_response.text:
        print("Users endpoint test failed!")
        sys.exit(1)
    
    print("Users endpoint test passed!")
    print("API verification successful! All tests passed.")
    sys.exit(0)
except Exception as e:
    print(f"API test failed with error: {e}")
    sys.exit(1)
EOF

# Copy the script to the pod
kubectl cp /tmp/verify-script.py template-fastapi-app/$POD_NAME:/tmp/verify-script.py

# Run the script in the pod
kubectl exec -n template-fastapi-app $POD_NAME -- bash -c "cd /app/src && python /tmp/verify-script.py"

# Check exit code
if [ $? -eq 0 ]; then
  echo "Verification completed successfully!"
  exit 0
else
  echo "Verification failed!"
  exit 1
fi 