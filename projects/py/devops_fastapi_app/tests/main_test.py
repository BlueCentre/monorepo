### pytest_test approach ###
# from fastapi.testclient import TestClient

# from projects.echo_fastapi_app.src import run

# client = TestClient(run)

# def test_read_main():
#     response = client.get("/status")
#     assert response.status_code == 200
#     assert response.json() == {"status": "UP", "version": "0.1.2"}


### py_test approach ###
import unittest
import json
import io
import sys
from unittest.mock import patch, MagicMock

# Import the app directly
from projects.py.devops_fastapi_app.bin.run_bin import DevOpsApp

class TestDevOpsApp(unittest.TestCase):
    def setUp(self):
        self.app = DevOpsApp()
    
    def test_get_root(self):
        response = self.app.get_root()
        self.assertEqual(response, {"message": "I am alive!!!"})
    
    def test_get_status(self):
        response = self.app.get_status()
        self.assertEqual(response, {"status": "UP", "version": "0.1.2"})
    
    def test_get_healthcheck(self):
        response = self.app.get_healthcheck()
        self.assertEqual(response, {"status": "UP", "msg": "degraded"})
    
    @patch('projects.py.devops_fastapi_app.bin.run_bin.PlatformOrganization')
    def test_get_devops(self, mock_platform_org):
        # Setup mock
        mock_devops = MagicMock()
        mock_devops.__str__.return_value = "InfrastructureEngineer<TestUser>"
        mock_platform_instance = MagicMock()
        mock_platform_instance.request_devops.return_value = mock_devops
        mock_platform_org.return_value = mock_platform_instance
        
        # Test
        response = self.app.get_devops("TestUser")
        self.assertEqual(response, {"devops": "InfrastructureEngineer<TestUser>"})
        mock_platform_org.assert_called_once()
        mock_platform_instance.request_devops.assert_called_once_with("TestUser")
    
    @patch('projects.py.devops_fastapi_app.bin.run_bin.PlatformOrganization')
    @patch('projects.py.devops_fastapi_app.bin.run_bin.random')
    def test_get_devops_random_item(self, mock_random, mock_platform_org):
        # Setup mocks
        mock_devops = MagicMock()
        mock_devops.__str__.return_value = "WebEngineer<RandomUser>"
        mock_platform_instance = MagicMock()
        mock_platform_instance.request_devops.return_value = mock_devops
        mock_platform_org.return_value = mock_platform_instance
        
        # Test
        response = self.app.get_devops_random_item("RandomUser")
        self.assertEqual(response, {"random_devops": "WebEngineer<RandomUser>"})
        mock_platform_org.assert_called_once()
        mock_platform_instance.request_devops.assert_called_once_with("RandomUser")

if __name__ == '__main__':
    unittest.main()
