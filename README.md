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
```

## Database Schema Updates

The initial database schema is loaded automatically when the database container is first created. For subsequent schema changes:

1. Update the `sql/schema.sql` file
2. Run the following command to apply changes:
   ```bash
   docker compose exec db mysql -u biomarker_user -pbiomarker_pass longevity < sql/schema.sql
   ```
3. Or use this shortcut ```make db-reset```