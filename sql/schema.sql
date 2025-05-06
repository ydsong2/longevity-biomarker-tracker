-- Longevity Biomarker Tracker Schema
-- Based on the ER model from the project documentation

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS BiologicalAgeResult;
DROP TABLE IF EXISTS ModelUsesBiomarker;
DROP TABLE IF EXISTS BiologicalAgeModel;
DROP TABLE IF EXISTS ReferenceRange;
DROP TABLE IF EXISTS Measurement;
DROP TABLE IF EXISTS Biomarker;
DROP TABLE IF EXISTS MeasurementSession;
DROP TABLE IF EXISTS User;

-- Create User table
CREATE TABLE User (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    SEQN INT UNIQUE,
    BirthDate DATE,
    Sex ENUM('M', 'F'),
    RaceEthnicity VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create MeasurementSession table
CREATE TABLE MeasurementSession (
    SessionID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    SessionDate DATE NOT NULL,
    FastingStatus BOOLEAN,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    UNIQUE KEY (UserID, SessionDate)
);

-- Create Biomarker table
CREATE TABLE Biomarker (
    BiomarkerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    NHANESVarCode VARCHAR(20) UNIQUE,
    Units VARCHAR(20) NOT NULL,
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Measurement table
CREATE TABLE Measurement (
    MeasurementID INT AUTO_INCREMENT PRIMARY KEY,
    SessionID INT NOT NULL,
    BiomarkerID INT NOT NULL,
    Value DECIMAL(12, 4) NOT NULL,
    TakenAt TIMESTAMP NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SessionID) REFERENCES MeasurementSession(SessionID),
    FOREIGN KEY (BiomarkerID) REFERENCES Biomarker(BiomarkerID),
    UNIQUE KEY (SessionID, BiomarkerID)
);

-- Create ReferenceRange table
CREATE TABLE ReferenceRange (
    RangeID INT AUTO_INCREMENT PRIMARY KEY,
    BiomarkerID INT NOT NULL,
    RangeType ENUM('clinical', 'longevity') NOT NULL,
    Sex ENUM('M', 'F', 'All'),
    AgeMin INT,
    AgeMax INT,
    MinVal DECIMAL(12, 4),
    MaxVal DECIMAL(12, 4),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BiomarkerID) REFERENCES Biomarker(BiomarkerID),
    UNIQUE KEY (BiomarkerID, RangeType, Sex, AgeMin, AgeMax)
);

-- Create BiologicalAgeModel table
CREATE TABLE BiologicalAgeModel (
    ModelID INT AUTO_INCREMENT PRIMARY KEY,
    ModelName VARCHAR(100) UNIQUE,
    Description TEXT,
    FormulaJSON JSON,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create ModelUsesBiomarker junction table (M:N relationship)
CREATE TABLE ModelUsesBiomarker (
    ModelID INT NOT NULL,
    BiomarkerID INT NOT NULL,
    Coefficient DECIMAL(10, 6),
    Transform VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ModelID, BiomarkerID),
    FOREIGN KEY (ModelID) REFERENCES BiologicalAgeModel(ModelID),
    FOREIGN KEY (BiomarkerID) REFERENCES Biomarker(BiomarkerID)
);

-- Create BiologicalAgeResult table
CREATE TABLE BiologicalAgeResult (
    ResultID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    ModelID INT NOT NULL,
    BioAgeYears DECIMAL(5, 2) NOT NULL,
    ComputedAt TIMESTAMP NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (ModelID) REFERENCES BiologicalAgeModel(ModelID),
    UNIQUE KEY (UserID, ModelID, ComputedAt)
);

-- Insert the nine biomarkers needed for Phenotypic Age calculation
INSERT INTO Biomarker (Name, NHANESVarCode, Units, Description) VALUES
('Albumin', 'LBXSAL', 'g/dL', 'Serum albumin'),
('Alkaline Phosphatase', 'LBXSAPSI', 'U/L', 'Alkaline phosphatase'),
('Creatinine', 'LBXSCR', 'mg/dL', 'Serum creatinine'),
('Fasting Glucose', 'LBXGLU', 'mg/dL', 'Plasma fasting glucose'),
('C-Reactive Protein', 'LBXHSCRP', 'mg/L', 'High-sensitivity C-reactive protein'),
('White Blood Cell Count', 'LBXWBCSI', '10³ cells/µL', 'White blood cell count'),
('Lymphocyte Percentage', 'LBXLYPCT', '%', 'Lymphocyte percentage'),
('Mean Corpuscular Volume', 'LBXMCVSI', 'fL', 'Mean corpuscular volume'),
('Red Cell Distribution Width', 'LBXRDW', '%', 'Red cell distribution width');

-- Insert the Phenotypic Age model
INSERT INTO BiologicalAgeModel (ModelName, Description, FormulaJSON) VALUES (
    'Phenotypic Age',
    'Morgan Levine''s Phenotypic Age clock (Levine et al., 2018)',
    '{"formula": "141.50 + ln(-0.00553*xb)*(-26.42)", "intercept": 141.50, "multiplier": -26.42, "internal_parameter": -0.00553}'
);

-- Insert the coefficients for the Phenotypic Age model
INSERT INTO ModelUsesBiomarker (ModelID, BiomarkerID, Coefficient, Transform) VALUES
(1, 1, -0.0336, 'none'),       -- Albumin
(1, 2, 0.0010, 'none'),        -- Alkaline Phosphatase
(1, 3, 0.0095, 'none'),        -- Creatinine
(1, 4, 0.0195, 'none'),        -- Glucose
(1, 5, 0.0954, 'log'),         -- CRP
(1, 6, 0.0268, 'none'),        -- WBC
(1, 7, -0.0020, 'none'),       -- Lymphocyte %
(1, 8, 0.0268, 'none'),        -- MCV
(1, 9, 0.3306, 'none');        -- RDW
