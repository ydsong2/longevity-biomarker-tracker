-- Longevity Biomarker Tracker · database schema
-- ================================================================
-- NOTE: pure DDL – no INSERTs, no seed data.  Seed rows now live in
--       sql/01_seed.sql so we can diff structure vs data separately
-- ================================================================

/* --------- housekeeping (idempotent) --------- */
DROP TABLE IF EXISTS BiologicalAgeResult;
DROP TABLE IF EXISTS ModelUsesBiomarker;
DROP TABLE IF EXISTS BiologicalAgeModel;
DROP TABLE IF EXISTS ReferenceRange;
DROP TABLE IF EXISTS Measurement;
DROP TABLE IF EXISTS Biomarker;
DROP TABLE IF EXISTS MeasurementSession;
DROP TABLE IF EXISTS User;

/* --------- User --------- */
CREATE TABLE User (
    UserID         INT AUTO_INCREMENT PRIMARY KEY,
    SEQN           INT UNIQUE,
    BirthDate      DATE,
    Sex            ENUM('M','F'),
    RaceEthnicity  VARCHAR(50),
    CreatedAt      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* --------- MeasurementSession --------- */
CREATE TABLE MeasurementSession (
    SessionID   INT AUTO_INCREMENT PRIMARY KEY,
    UserID      INT NOT NULL,
    SessionDate DATE NOT NULL,
    FastingStatus  BOOLEAN,
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY  (UserID, SessionDate),
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

/* --------- Biomarker --------- */
CREATE TABLE Biomarker (
    BiomarkerID   INT AUTO_INCREMENT PRIMARY KEY,
    Name          VARCHAR(100) NOT NULL,
    NHANESVarCode VARCHAR(20) UNIQUE,
    Units         VARCHAR(20)  NOT NULL,
    Description   TEXT,
    CreatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* --------- Measurement --------- */
CREATE TABLE Measurement (
    MeasurementID INT AUTO_INCREMENT PRIMARY KEY,
    SessionID     INT NOT NULL,
    BiomarkerID   INT NOT NULL,
    Value         DECIMAL(12,4) NOT NULL,
    TakenAt       TIMESTAMP     NOT NULL,
    CreatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY  (SessionID, BiomarkerID),
    FOREIGN KEY (SessionID)   REFERENCES MeasurementSession(SessionID),
    FOREIGN KEY (BiomarkerID) REFERENCES Biomarker(BiomarkerID)
);

/* --------- ReferenceRange --------- */
CREATE TABLE ReferenceRange (
    RangeID     INT AUTO_INCREMENT PRIMARY KEY,
    BiomarkerID INT NOT NULL,
    RangeType   ENUM('clinical','longevity') NOT NULL,
    Sex         ENUM('M','F','All'),
    AgeMin      INT,
    AgeMax      INT,
    MinVal      DECIMAL(12,4),
    MaxVal      DECIMAL(12,4),
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY  (BiomarkerID, RangeType, Sex, AgeMin, AgeMax),
    FOREIGN KEY (BiomarkerID) REFERENCES Biomarker(BiomarkerID)
);

/* --------- BiologicalAgeModel --------- */
CREATE TABLE BiologicalAgeModel (
    ModelID    INT AUTO_INCREMENT PRIMARY KEY,
    ModelName  VARCHAR(100) UNIQUE,
    Description TEXT,
    FormulaJSON JSON,
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* --------- ModelUsesBiomarker (junction) --------- */
CREATE TABLE ModelUsesBiomarker (
    ModelID     INT NOT NULL,
    BiomarkerID INT NOT NULL,
    Coefficient DECIMAL(10,6),
    Transform   VARCHAR(50),
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ModelID, BiomarkerID),
    FOREIGN KEY (ModelID)     REFERENCES BiologicalAgeModel(ModelID),
    FOREIGN KEY (BiomarkerID) REFERENCES Biomarker(BiomarkerID)
);

/* --------- BiologicalAgeResult --------- */
CREATE TABLE BiologicalAgeResult (
    ResultID     INT AUTO_INCREMENT PRIMARY KEY,
    UserID       INT NOT NULL,
    ModelID      INT NOT NULL,
    BioAgeYears  DECIMAL(5,2) NOT NULL,
    ComputedAt   TIMESTAMP NOT NULL,
    CreatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (UserID, ModelID, ComputedAt),
    FOREIGN KEY (UserID)  REFERENCES User(UserID),
    FOREIGN KEY (ModelID) REFERENCES BiologicalAgeModel(ModelID)
);
