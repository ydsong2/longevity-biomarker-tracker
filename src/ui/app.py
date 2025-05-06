"""Placeholder app front end"""

import streamlit as st
import requests
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# API URL
API_URL = os.getenv("APP_API_URL", "http://localhost:8000")

# Set page title
st.set_page_config(
    page_title="Longevity Biomarker Dashboard",
    page_icon="🧬",
    layout="wide"
)

st.title("🧬 Longevity Biomarker Dashboard")

# Add sidebar
st.sidebar.header("Navigation")
page = st.sidebar.radio("Select Page", ["Home", "User Profile", "Biomarkers", "Biological Age"])

# Home page content
if page == "Home":
    st.header("Welcome to the Longevity Biomarker Tracker")
    st.write("This dashboard allows you to explore biological age calculations and biomarker data.")

    # Check API connection
    try:
        response = requests.get(f"{API_URL}/")
        if response.status_code == 200:
            st.success(f"Connected to API: {response.json()['message']}")
        else:
            st.error(f"API Error: Status code {response.status_code}")
    except Exception as e:
        st.error(f"Failed to connect to API: {e}")

    st.info("Select a page from the sidebar to begin exploring data.")
else:
    st.info(f"The {page} page is under development. Please check back soon!")