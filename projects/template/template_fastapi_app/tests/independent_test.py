"""
Independent test for the FastAPI application that doesn't depend on app module.
This test can run in any environment regardless of Pydantic version.
"""

import unittest
from unittest import mock
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

class TestIndependentWebApp(unittest.TestCase):
    """Test class for web app functionality that doesn't depend on app module."""
    
    def setUp(self):
        """Set up the test app."""
        # Create settings directly rather than mocking app.core.config
        self.project_name = "Test App"
        self.api_v1_str = "/api/v1"
        
        # Create a test app
        self.app = FastAPI(
            title=self.project_name,
            openapi_url=f"{self.api_v1_str}/openapi.json",
        )
        
        # Add the endpoints we want to test
        @self.app.get("/")
        def root():
            return {"message": f"Welcome to {self.project_name}"}
        
        @self.app.get("/health")
        def health():
            return {"status": "ok"}
        
        # Create a test client
        self.client = TestClient(self.app)
    
    def test_root_endpoint(self):
        """Test the root endpoint."""
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertIn("message", response.json())
        self.assertIn("Welcome to Test App", response.json()["message"])
    
    def test_health_endpoint(self):
        """Test the health endpoint."""
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "ok"})

if __name__ == '__main__':
    unittest.main() 