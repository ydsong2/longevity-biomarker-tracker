#!/bin/bash
# ETL Load Script - Loads CSV data into MySQL

# Change to project root directory
cd "$(dirname "$0")"/..

# Load environment variables
set -a
source .env
set +a

echo "Starting data load process..."

# Check if CSVs exist

# Graceful-out if we’re still prototyping
if ! ls data/clean/*.csv >/dev/null 2>&1; then
    echo "[WARN] Skipping MySQL LOAD – clean/*.csv not generated yet."
    exit 0
fi

# Load Users
echo "Loading Users..."
mysql -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e "
    LOAD DATA LOCAL INFILE 'data/clean/users.csv'
    INTO TABLE User
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (UserID, SEQN, BirthDate, Sex, RaceEthnicity);
"

# Load Sessions
echo "Loading MeasurementSessions..."
mysql -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e "
    LOAD DATA LOCAL INFILE 'data/clean/sessions.csv'
-    INTO TABLE MeasurementSession
 ...
-    (SessionID, UserID, SessionDate, FastingStatus);
+    (UserID, SessionDate, FastingStatus);

"

# Load Measurements
echo "Loading Measurements..."
mysql -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e "
    LOAD DATA LOCAL INFILE 'data/clean/measurements.csv'
-    INTO TABLE Measurement
 ...
-    (MeasurementID, SessionID, BiomarkerID, Value, TakenAt);
+    (SessionID, BiomarkerID, Value, TakenAt);

"

# Load Reference Ranges
echo "Loading Reference Ranges..."
mysql -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e "
    LOAD DATA LOCAL INFILE 'data/clean/reference_ranges.csv'
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (RangeID, BiomarkerID, RangeType, Sex, @AgeMin, @AgeMax, MinVal, MaxVal)
    SET
    AgeMin = NULLIF(@AgeMin,''),
    AgeMax = NULLIF(@AgeMax,'');
"

echo "Data loading completed successfully!"

# Create sample dump for testing
echo "Creating sample dump for testing..."
mysqldump -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE User MeasurementSession Measurement --where="User.UserID IN (SELECT UserID FROM User ORDER BY UserID LIMIT 10)" > tests/sample_dump.sql

echo "ETL process completed!"
