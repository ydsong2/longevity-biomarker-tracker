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
    (SEQN, BirthDate, Sex, RaceEthnicity);

"

echo "Loading MeasurementSessions..."
mysql -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e "
    LOAD DATA LOCAL INFILE 'data/clean/sessions.csv'
    INTO TABLE MeasurementSession
    FIELDS TERMINATED BY ',' ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (UserID, SessionDate, FastingStatus);
"

echo "Loading Measurements..."
mysql -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e "
    LOAD DATA LOCAL INFILE 'data/clean/measurements.csv'
    INTO TABLE Measurement
    FIELDS TERMINATED BY ',' ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (SessionID, BiomarkerID, Value, TakenAt);
"


# ------------------------------------------------------------------
# 👇 Sample dump for the CI suite (small but relationally consistent)
# ------------------------------------------------------------------
echo "Creating sample dump for testing..."

# 1) Dump 10 most-recent users
mysqldump -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE \
  User \
  --where="UserID IN (SELECT u.UserID
                       FROM (SELECT UserID
                               FROM User
                              ORDER BY CreatedAt DESC
                              LIMIT 10) AS u)" \
  --skip-add-drop-table \
  --skip-lock-tables \
  > tests/sample_dump.sql

# 2) Dump every session that belongs to those users
mysqldump -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE \
  MeasurementSession \
  --where="UserID IN (SELECT u.UserID
                       FROM (SELECT UserID
                               FROM User
                              ORDER BY CreatedAt DESC
                              LIMIT 10) AS u)" \
  --no-create-info \
  --skip-add-drop-table \
  --skip-lock-tables \
  >> tests/sample_dump.sql

# 3) Dump every measurement that belongs to those sessions
mysqldump -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE \
  Measurement \
  --where="SessionID IN (SELECT s.SessionID
                          FROM (SELECT SessionID
                                  FROM MeasurementSession
                                 WHERE UserID IN (SELECT UserID
                                                    FROM User
                                                   ORDER BY CreatedAt DESC
                                                   LIMIT 10)) AS s)" \
  --no-create-info \
  --skip-add-drop-table \
  --skip-lock-tables \
  >> tests/sample_dump.sql

echo "Sample dump written to tests/sample_dump.sql"


echo "Data loading completed successfully!"
