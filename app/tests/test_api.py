from unittest.mock import patch

from fastapi.testclient import TestClient

from src.main import app


client = TestClient(app)


@patch("src.main.get_backend_type", return_value="postgres")
def test_healthz(mock_backend):
    response = client.get("/healthz")

    assert response.status_code == 200

    body = response.json()
    assert body["status"] == "ok"
    assert body["db"] == "postgres"
    assert isinstance(body["ts"], int)


@patch("src.main.put_mapping")
def test_shorten_url(mock_put_mapping):
    response = client.post(
        "/shorten",
        json={"url": "https://example.com"},
    )

    assert response.status_code == 200

    body = response.json()

    assert body["short"] == "100680ad"
    assert body["url"] == "https://example.com"
    assert body["short_url"] == "100680ad"

    mock_put_mapping.assert_called_once_with(
        "100680ad",
        "https://example.com",
    )


def test_shorten_requires_url():
    response = client.post("/shorten", json={})

    assert response.status_code == 400
    assert response.json()["detail"] == "url required"


@patch("src.main.get_mapping")
def test_stats_existing_url(mock_get_mapping):
    mock_get_mapping.return_value = {
        "url": "https://example.com",
        "clicks": 3,
    }

    response = client.get("/stats/abc123")

    assert response.status_code == 200
    assert response.json() == {
        "short": "abc123",
        "url": "https://example.com",
        "clicks": 3,
    }


@patch("src.main.get_mapping", return_value=None)
def test_stats_missing_url(mock_get_mapping):
    response = client.get("/stats/missing")

    assert response.status_code == 404
    assert response.json()["detail"] == "not found"


@patch("src.main.publish_click_event")
@patch("src.main.increment_clicks")
@patch("src.main.get_mapping")
@patch("src.main.get_url", return_value=None)
@patch("src.main.set_url")
def test_redirect_from_database(
    mock_set_url,
    mock_get_url,
    mock_get_mapping,
    mock_increment_clicks,
    mock_publish_click_event,
):
    mock_get_mapping.return_value = {
        "url": "https://example.com",
        "clicks": 0,
    }

    response = client.get(
        "/abc123",
        follow_redirects=False,
    )

    assert response.status_code == 307
    assert response.headers["location"] == "https://example.com"

    mock_get_mapping.assert_called_once_with("abc123")
    mock_set_url.assert_called_once_with(
        "abc123",
        "https://example.com",
    )
    mock_increment_clicks.assert_called_once_with("abc123")
    mock_publish_click_event.assert_called_once()