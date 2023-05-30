from fastapi.testclient import TestClient

from exp_python.webapp.main import app

client = TestClient(app)


def test_read_main():
    response = client.get("/status")
    assert response.status_code == 200
    assert response.json() == {"status": "UP", "version": "0.1.0"}
