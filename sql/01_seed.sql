-- Longevity Biomarker Tracker · seed data
-- Executed right after schema.sql in local Makefile & CI
-- ========================================================

/* --- 9 biomarkers used by the Phenotypic-Age clock --- */
INSERT INTO Biomarker (Name, NHANESVarCode, Units, Description) VALUES
  ('Albumin',                'LBXSAL',    'g/dL',  'Serum albumin'),
  ('Alkaline Phosphatase',   'LBXSAPSI',  'U/L',   'Alkaline phosphatase'),
  ('Creatinine',             'LBXSCR',    'mg/dL', 'Serum creatinine'),
  ('Fasting Glucose',        'LBXGLU',    'mg/dL', 'Plasma fasting glucose'),
  ('C-Reactive Protein',     'LBXHSCRP',  'mg/L',  'High-sensitivity CRP'),
  ('White Blood Cell Count', 'LBXWBCSI',  '10³/µL','WBC count'),
  ('Lymphocyte Percentage',  'LBXLYPCT',  '%',     'Lymphocyte %'),
  ('Mean Corpuscular Volume','LBXMCVSI',  'fL',    'MCV'),
  ('Red Cell Distribution Width','LBXRDW','%',     'RDW');

/* --- Phenotypic-Age model meta row --- */
INSERT INTO BiologicalAgeModel (ModelName, Description, FormulaJSON) VALUES
  ('Phenotypic Age',
   'Morgan Levine et al. (2018)',
   '{"formula":"141.50 + ln(-0.00553*xb)*(-26.42)",'
   '"intercept":141.50,"multiplier":-26.42,"internal_parameter":-0.00553}');

/* --- Coefficients for the model --- */
INSERT INTO ModelUsesBiomarker (ModelID, BiomarkerID, Coefficient, Transform) VALUES
  (1,1,-0.0336,'none'),
  (1,2, 0.0010,'none'),
  (1,3, 0.0095,'none'),
  (1,4, 0.0195,'none'),
  (1,5, 0.0954,'log'),
  (1,6, 0.0268,'none'),
  (1,7,-0.0020,'none'),
  (1,8, 0.0268,'none'),
  (1,9, 0.3306,'none');
