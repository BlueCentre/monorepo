#!/usr/bin/env python3
"""
Tests for the DevOps FastAPI Application using FastAPI's TestClient.

These tests verify the functionality of the DevOps FastAPI application endpoints.
"""

import os
import sys
import unittest
from unittest.mock import MagicMock, patch

# Add the parent directory to sys.path to allow importing from app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient

from app.web_app import app


class TestDevOpsApp(unittest.TestCase):
    """Test cases for the DevOps FastAPI application."""

    def setUp(self) -> None:
        """
        Set up the test environment before each test.

        Initializes the TestClient for the FastAPI app.
        """
        self.client = TestClient(app)

    def test_root_endpoint(self) -> None:
        """
        Test the root endpoint.

        Verifies that the root endpoint returns a status code of 200
        and the expected message.
        """
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"message": "I am alive"})

    def test_status_endpoint(self) -> None:
        """
        Test the status endpoint.

        Verifies that the status endpoint returns a status code of 200
        and the expected status and version.
        """
        response = self.client.get("/status")
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn("status", data)
        self.assertIn("version", data)
        self.assertEqual(data["status"], "UP")
        self.assertEqual(data["version"], "0.1.0")

    def test_healthcheck_endpoint(self) -> None:
        """
        Test the healthcheck endpoint.

        Verifies that the healthcheck endpoint returns a status code of 200
        and the expected health status.
        """
        response = self.client.get("/healthcheck")
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn("status", data)
        self.assertIn("details", data)
        self.assertEqual(data["status"], "UP")
        self.assertIsInstance(data["details"], dict)

        # Check that details has the expected components
        details = data["details"]
        self.assertIn("database", details)
        self.assertIn("cache", details)
        self.assertIn("storage", details)

    @patch("app.routes.PlatformOrganization")
    def test_devops_endpoint(self, mock_platform_organization) -> None:
        """
        Test the devops endpoint.

        Verifies that the devops endpoint returns a status code of 200
        and the expected DevOps role information.
        """
        # Set up the mock
        mock_devops = MagicMock()
        mock_devops.name = "TestDevOps"
        mock_devops.__class__.__name__ = "InfrastructureEngineer"
        mock_devops.speak.return_value = None  # The speak method prints, doesn't return

        mock_platform_instance = MagicMock()
        mock_platform_instance.request_devops.return_value = mock_devops

        mock_platform_organization.return_value = mock_platform_instance

        # Test the endpoint
        response = self.client.get("/devops/TestDevOps")
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn("name", data)
        self.assertIn("type", data)
        self.assertIn("message", data)
        self.assertEqual(data["name"], "TestDevOps")
        self.assertEqual(data["type"], "InfrastructureEngineer")

    @patch("app.routes.random_platform")
    def test_devops_random_endpoint(self, mock_random_platform) -> None:
        """
        Test the devops random endpoint.

        Verifies that the devops random endpoint returns a status code of 200
        and the expected random DevOps role information.
        """
        # Set up the mock
        mock_devops = MagicMock()
        mock_devops.name = "RandomDevOps"
        mock_devops.__class__.__name__ = "DataEngineer"
        mock_devops.speak.return_value = None  # The speak method prints, doesn't return

        mock_random_platform.return_value = mock_devops

        # Test the endpoint
        response = self.client.get("/devops/random/RandomDevOps")
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn("name", data)
        self.assertIn("type", data)
        self.assertIn("message", data)
        self.assertEqual(data["name"], "RandomDevOps")
        self.assertEqual(data["type"], "DataEngineer")

    def test_not_found(self) -> None:
        """
        Test accessing a non-existent endpoint.

        Verifies that accessing a non-existent endpoint returns a 404 status code.
        """
        response = self.client.get("/non-existent-endpoint")
        self.assertEqual(response.status_code, 404)


if __name__ == "__main__":
    unittest.main()
