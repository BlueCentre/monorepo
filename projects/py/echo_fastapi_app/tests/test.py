#!/usr/bin/env python3
"""
Test file for the Echo FastAPI App using FastAPI's TestClient.
"""

import os
import sys
import unittest

from fastapi.testclient import TestClient

# Add the parent directory to the path to allow importing from app
sys.path.insert(
    0,
    os.path.abspath(
        os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    ),
)

# Import the FastAPI app
from app.web_app import app


class TestEchoApp(unittest.TestCase):
    """Test cases for the Echo FastAPI App."""

    def setUp(self):
        """Set up the test client before each test."""
        self.client = TestClient(app)

    def test_root_endpoint(self):
        """Test the root endpoint."""
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["message"], "I am alive")

    def test_status_endpoint(self):
        """Test the status endpoint."""
        response = self.client.get("/status")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "UP")
        self.assertEqual(data["version"], "0.1.0")

    def test_health_endpoint(self):
        """Test the health endpoint."""
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "UP")
        self.assertTrue("details" in data)
        self.assertTrue(isinstance(data["details"], dict))

    def test_echo_endpoint(self):
        """Test the echo endpoint."""
        test_message = "hello world"
        response = self.client.get(f"/echo/{test_message}")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["message"], test_message)

    def test_not_found(self):
        """Test a non-existent endpoint."""
        response = self.client.get("/non-existent-endpoint")
        self.assertEqual(response.status_code, 404)


if __name__ == "__main__":
    unittest.main()
