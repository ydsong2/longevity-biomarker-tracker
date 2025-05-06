"""Basic test harness for database."""


import pytest
import os
import pymysql
from dotenv import load_dotenv
from fastapi.testclient import TestClient
import pathlib
import sys

# --- make project root importable ---
ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.append(str(ROOT))
# ------------------------------------
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


@pytest.fixture
def db_connection():
    """Fixture to create a database connection for tests."""
    connection = pymysql.connect(**DB_CONFIG)
    yield connection
    connection.close()


@pytest.fixture
def db_cursor(db_connection):
    """Fixture to create a database cursor for tests."""
    cursor = db_connection.cursor()
    yield cursor
    cursor.close()
