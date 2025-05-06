# Longevity Biomarker Tracking System

Database system for tracking biomarkers and calculating biological age based on NHANES data.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/longevity-biomarker-tracker.git
cd longevity-biomarker-tracker

# Copy environment variables and install dependencies
cp .env.example .env
make install

# Start the database
make db

# Run ETL process (downloads NHANES data, skips transform if not ready, loads schema)
make etl

# Load environment variables before running the API and UI
source .env

# Start the API server
make run

# In a new terminal, start the UI dashboard (press Enter when asked for email)
make ui
```

## Database Schema Updates

The initial database schema is loaded automatically when the database container is first created. For subsequent schema changes:

1. Update the `sql/schema.sql` file
2. Run the following command to apply changes:
   ```bash
   docker compose exec db mysql -u biomarker_user -pbiomarker_pass longevity < sql/schema.sql
   ```
3. Or use this shortcut ```make db-reset```