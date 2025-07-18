"""Basic test harness for database."""


import pytest
import os
import pymysql
from dotenv import load_dotenv
from fastapi.testclient import TestClient
from src.api.main import app


# Load environment variables
load_dotenv()

# Database configuration
DB_CONFIG = {
    "host": "localhost",
    "port": int(os.getenv("MYSQL_PORT", 3307)),
    "user": os.getenv("MYSQL_USER", "biomarker_user"),
    "password": os.getenv("MYSQL_PASSWORD", "biomarker_pass"),
    "db": os.getenv("MYSQL_DATABASE", "longevity"),
    "charset": "utf8mb4",
    "cursorclass": pymysql.cursors.DictCursor,
}


@pytest.fixture(scope="session")
def api_client():
    """Return a synchronous TestClient for the FastAPI app."""
    with TestClient(app) as client:
        yield client


@pytest.fixture(scope="session")
def db_connection():
    """Fixture to create a database connection for tests."""
    connection = pymysql.connect(**DB_CONFIG)
    yield connection
    connection.close()


# Make cursor session-scoped so a session-scoped fixture can depend on it
@pytest.fixture(scope="session")
def db_cursor(db_connection):
    """Fixture to create a database cursor for tests."""
    cursor = db_connection.cursor()
    yield cursor
    cursor.close()


@pytest.fixture(scope="session", autouse=True)
def ensure_demo_user(db_cursor):
    db_cursor.execute("SELECT COUNT(*) AS c FROM User")
    if db_cursor.fetchone()["c"] == 0:
        db_cursor.execute(
            "INSERT INTO User (SEQN, BirthDate, Sex, RaceEthnicity) "
            "VALUES (999999, '1970-01-01', 'M', 'Sample')"
        )
