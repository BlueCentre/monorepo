from fastapi.testclient import TestClient

#from webapp.main import app
import run

client = TestClient(run)


def test_read_main():
    response = client.get("/status")
    assert response.status_code == 200
    assert response.json() == {"status": "UP", "version": "0.1.1"}
