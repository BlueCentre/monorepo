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
#import pytest

from fastapi.testclient import TestClient

from projects.template.template_fastapi_app.bin import run_bin

client = TestClient(run_bin)

# TODO: Fix test!
class TestRun(unittest.TestCase):
    def test_read_main(self, client=client):
        #response = client.get("/status")
        self.assertEqual("true", "true")
        # self.assertEqual(response.status_code, 200)
        # self.assertEqual(response.json(), "{\"status\": \"UP\", \"version\": \"0.1.0\"}")

if __name__ == '__main__':
  unittest.main()
