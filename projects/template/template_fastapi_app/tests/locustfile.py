"""
Load testing script for FastAPI application.

This file defines user behaviors for load testing with Locust.
Run with: locust -f tests/locustfile.py
"""

import random
import json
import uuid
import logging
try:
    from locust import HttpUser, task, between, events
    LOCUST_AVAILABLE = True
except ImportError:
    # Create placeholders if locust is not available
    def task(weight=1): return lambda f: f
    def between(*args, **kwargs): return lambda: None
    events = None
    HttpUser = object
    LOCUST_AVAILABLE = False

# Configure logging
logger = logging.getLogger(__name__)


class FastAPIUser(HttpUser):
    """User behavior for load testing the FastAPI application."""
    
    wait_time = between(1, 3)  # Wait between 1 and 3 seconds between tasks (reduced for CI)
    access_token = None
    user_id = None
    item_ids = []
    
    def on_start(self):
        """Set up tasks to run before simulations begin."""
        if not LOCUST_AVAILABLE:
            logger.warning("Locust is not available. Load testing will not work.")
            return
            
        try:
            self.login()
            self.create_test_data()
        except Exception as e:
            logger.error(f"Error in on_start: {str(e)}")
    
    def login(self):
        """Log in and obtain access token."""
        try:
            # Register a user first to ensure we have valid credentials
            user_id = str(uuid.uuid4())[:8]
            email = f"loadtest_{user_id}@example.com"
            password = "password123"
            
            # Create user
            with self.client.post(
                "/api/v1/users/",
                json={
                    "email": email,
                    "password": password,
                    "full_name": "Load Test User"
                },
                name="/api/v1/users/ - Create User",
                catch_response=True
            ) as response:
                if response.status_code == 201:
                    self.user_id = response.json().get("id")
                    logger.info(f"Created test user with ID: {self.user_id}")
                else:
                    response.failure(f"Failed to create user: {response.text}")
                    return
                
                # Login to get token
                with self.client.post(
                    "/api/v1/login/access-token",
                    data={"username": email, "password": password},
                    headers={"Content-Type": "application/x-www-form-urlencoded"},
                    name="/api/v1/login/access-token - Login",
                    catch_response=True
                ) as login_response:
                    if login_response.status_code == 200:
                        data = login_response.json()
                        self.access_token = data.get("access_token")
                        
                        # Set authorization header for all subsequent requests
                        self.client.headers.update({"Authorization": f"Bearer {self.access_token}"})
                        logger.info("Successfully obtained access token")
                    else:
                        login_response.failure(f"Failed to login: {login_response.text}")
        except Exception as e:
            logger.error(f"Error in login: {str(e)}")
    
    def create_test_data(self):
        """Create test data for load testing."""
        if not self.access_token:
            logger.warning("No access token available, skipping test data creation")
            return
            
        try:
            # Create items for testing (reduced number for CI)
            for i in range(2):  # Reduced from 5 to 2
                with self.client.post(
                    "/api/v1/items/",
                    json={"title": f"Load Test Item {i}", "description": f"Description for load test item {i}"},
                    name="/api/v1/items/ - Create Item",
                    catch_response=True
                ) as response:
                    if response.status_code == 200:
                        item_id = response.json().get("id")
                        if item_id:
                            self.item_ids.append(item_id)
                            logger.info(f"Created test item with ID: {item_id}")
                    else:
                        response.failure(f"Failed to create item: {response.text}")
        except Exception as e:
            logger.error(f"Error in create_test_data: {str(e)}")
    
    @task(3)
    def get_items(self):
        """Get list of items."""
        if not self.access_token:
            return
            
        try:
            with self.client.get(
                "/api/v1/items/", 
                name="/api/v1/items/ - Get Items",
                catch_response=True
            ) as response:
                if response.status_code != 200:
                    response.failure(f"Failed to get items: {response.text}")
        except Exception as e:
            logger.error(f"Error in get_items: {str(e)}")
    
    @task(2)
    def get_single_item(self):
        """Get a single item."""
        if not self.access_token or not self.item_ids:
            return
            
        try:
            item_id = random.choice(self.item_ids)
            with self.client.get(
                f"/api/v1/items/{item_id}", 
                name="/api/v1/items/{id} - Get Single Item",
                catch_response=True
            ) as response:
                if response.status_code != 200:
                    response.failure(f"Failed to get item {item_id}: {response.text}")
        except Exception as e:
            logger.error(f"Error in get_single_item: {str(e)}")
    
    @task(1)
    def create_item(self):
        """Create a new item."""
        if not self.access_token:
            return
            
        try:
            item_num = random.randint(1000, 9999)
            with self.client.post(
                "/api/v1/items/",
                json={
                    "title": f"New Item {item_num}",
                    "description": f"Description for item {item_num}"
                },
                name="/api/v1/items/ - Create New Item",
                catch_response=True
            ) as response:
                if response.status_code == 200:
                    new_id = response.json().get("id")
                    if new_id:
                        self.item_ids.append(new_id)
                        logger.info(f"Created new item with ID: {new_id}")
                else:
                    response.failure(f"Failed to create new item: {response.text}")
        except Exception as e:
            logger.error(f"Error in create_item: {str(e)}")
    
    @task(1)
    def update_item(self):
        """Update an existing item."""
        if not self.access_token or not self.item_ids:
            return
            
        try:
            item_id = random.choice(self.item_ids)
            with self.client.put(
                f"/api/v1/items/{item_id}",
                json={
                    "title": f"Updated Item {random.randint(1000, 9999)}",
                    "description": f"Updated description {random.randint(1000, 9999)}"
                },
                name="/api/v1/items/{id} - Update Item",
                catch_response=True
            ) as response:
                if response.status_code != 200:
                    response.failure(f"Failed to update item {item_id}: {response.text}")
        except Exception as e:
            logger.error(f"Error in update_item: {str(e)}")
    
    @task(1)
    def get_current_user(self):
        """Get current user info."""
        if not self.access_token:
            return
            
        try:
            with self.client.get(
                "/api/v1/users/me", 
                name="/api/v1/users/me - Get Current User",
                catch_response=True
            ) as response:
                if response.status_code != 200:
                    response.failure(f"Failed to get current user: {response.text}")
        except Exception as e:
            logger.error(f"Error in get_current_user: {str(e)}")
    
    @task(1)
    def get_health_check(self):
        """Get health status."""
        try:
            with self.client.get(
                "/health", 
                name="/health - Health Check",
                catch_response=True
            ) as response:
                if response.status_code != 200:
                    response.failure(f"Failed health check: {response.text}")
        except Exception as e:
            logger.error(f"Error in get_health_check: {str(e)}")


# Only set up event handlers if locust is available
if LOCUST_AVAILABLE and events:
    @events.test_start.add_listener
    def on_test_start(environment, **kwargs):
        """Event that fires when the load test starts."""
        logger.info("Starting load test...")


    @events.test_stop.add_listener
    def on_test_stop(environment, **kwargs):
        """Event that fires when the load test stops."""
        logger.info("Load test completed!")


# Skip load testing in CI by default
if __name__ == "__main__":
    if not LOCUST_AVAILABLE:
        print("Locust is not installed. Please install it to run load tests.")
        exit(1)
    print("Run this load test with: locust -f tests/locustfile.py --host=http://localhost:8000")


# Command to run this test:
# locust -f tests/locustfile.py --host=http://localhost:8000 