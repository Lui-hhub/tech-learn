from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_profile_returns_200():
    res = client.get("/api/profile")
    assert res.status_code == 200


def test_profile_has_required_fields():
    res = client.get("/api/profile")
    data = res.json()
    assert "heroTitle" in data
    assert "identity" in data
    assert "motto" in data["identity"]


def test_analyze_returns_score():
    res = client.post("/api/analyze", json={"text": "今天天气不错"})
    assert res.status_code == 200
    data = res.json()
    assert "score" in data
    assert 0 <= data["score"] <= 1
