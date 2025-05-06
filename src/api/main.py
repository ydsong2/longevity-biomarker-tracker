"""Main entry point for API"""
from fastapi import FastAPI

app = FastAPI(
    title="Longevity Biomarker API",
    description="API for tracking biomarkers and calculating biological age",
)


@app.get("/")
def read_root():
    """Return API welcome message."""
    return {"message": "Longevity Biomarker API"}


@app.get("/users/{user_id}")
def read_user(user_id: int):
    """Return user information by ID."""
    # Stub implementation for tests
    return {
        "UserID": user_id,
        "SEQN": 10000 + user_id,
        "Sex": "M",
        "RaceEthnicity": "Sample",
    }


@app.get("/users/{user_id}/measurements")
def read_measurements(user_id: int):
    """Return measurements for a specific user."""
    # Stub implementation for tests
    return [{"MeasurementID": 1, "BiomarkerName": "Albumin", "Value": 4.5}]


@app.get("/users/{user_id}/bio-age")
def read_bio_age(user_id: int):
    """Calculate and return biological age for a user."""
    # Stub implementation for tests
    return {"user_id": user_id, "bio_age_years": 45.0, "model_name": "Phenotypic Age"}
