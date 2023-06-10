import unittest
from unittest.mock import patch

from libs.devops.models.devops import InfrastructureEngineer, PlatformOrganization


class TestPlatformOrganization(unittest.TestCase):
    def test_infrastructureengineer_platformorganization_shall_show_infrastructureengineer_instance(self):
        infrastructureengineer_platformorganization = PlatformOrganization(InfrastructureEngineer)
        with patch.object(InfrastructureEngineer, "speak") as mock_InfrastructureEngineer_speak:
            devops = infrastructureengineer_platformorganization.request_devops("")
            devops.speak()
            self.assertEqual(mock_InfrastructureEngineer_speak.call_count, 1)

if __name__ == '__main__':
  unittest.main()
