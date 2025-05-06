"""Test harness for API"""

import pytest
import requests
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# API URL
API_URL = os.getenv("API_URL", "http://localhost:8000")

def test_api_root():
    """Test the API root endpoint."""
    response = requests.get(f"{API_URL}/")
    assert response.status_code == 200
    assert "message" in response.json()

def test_get_user():
    """Test getting a user by ID."""
    user_id = 1  # Assuming user 1 exists in the test database
    response = requests.get(f"{API_URL}/users/{user_id}")
    assert response.status_code == 200
    user = response.json()
    assert "UserID" in user
    assert user["UserID"] == user_id

def test_get_measurements():
    """Test getting measurements for a user."""
    user_id = 1  # Assuming user 1 has measurements
    response = requests.get(f"{API_URL}/users/{user_id}/measurements")
    assert response.status_code == 200
    measurements = response.json()
    assert isinstance(measurements, list)
    # If the user has measurements, check structure
    if measurements:
        assert "MeasurementID" in measurements[0]
        assert "BiomarkerName" in measurements[0]
        assert "Value" in measurements[0]

def test_bio_age_calculation():
    """Test the biological age calculation endpoint."""
    user_id = 1  # Assuming user 1 exists
    response = requests.get(f"{API_URL}/users/{user_id}/bio-age")
    assert response.status_code == 200
    bio_age = response.json()
    assert "user_id" in bio_age
    assert "bio_age_years" in bio_age
    assert "model_name" in bio_age