"""Test harness for API."""


def test_api_toot(api_client):
    """Testing API for response"""
    response = api_client.get("/")
    assert response.status_code == 200
    assert response.json()["message"].startswith("Longevity Biomarker")


def test_get_user(api_client):
    """Test getting a user by ID."""
    user_id = 1  # Assuming user 1 exists in the test database
    response = api_client.get(f"/users/{user_id}")
    assert response.status_code == 200
    user = response.json()
    assert "UserID" in user
    assert user["UserID"] == user_id


def test_get_measurements(api_client):
    """Test getting measurements for a user."""
    user_id = 1  # Assuming user 1 has measurements
    response = api_client.get(f"/users/{user_id}/measurements")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_bio_age_calculation(api_client):
    """Test the biological age calculation endpoint."""
    user_id = 1  # Assuming user 1 exists
    response = api_client.get(f"/users/{user_id}/bio-age")
    assert response.status_code == 200
    payload = response.json()
    assert payload["user_id"] == user_id
