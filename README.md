# Longevity Biomarker Tracking System

Database system for tracking biomarkers and calculating biological age based on NHANES data.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/longevity-biomarker-tracker.git
cd longevity-biomarker-tracker

# Copy environment variables and modify if needed
cp .env.example .env

# Start the database
make db

# Run ETL process (download NHANES data, transform, and load)
make etl

# Run tests to ensure everything is working
make test

# Start the API server
make run

# In a new terminal, start the UI dashboard
make ui