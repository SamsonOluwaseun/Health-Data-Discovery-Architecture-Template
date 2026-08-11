-- ============================================================
--  Gov Health Data Discovery Template
--  File: 01_conceptual_entities.sql
--  Purpose: Conceptual-level entity definitions
--  Usage: Reverse-engineer into Erwin Data Modeler to build
--         the Conceptual Data Model
--
--  How to import into Erwin:
--    1. Open Erwin Data Modeler
--    2. Actions → Reverse Engineer
--    3. Select "Script File" and point to this file
--    4. Choose target DB: PostgreSQL
--    5. Review generated entities and add relationships
--
--  Author: [Your Name] | [Engagement Name]
-- ============================================================

-- NOTE: These are CONCEPTUAL definitions only.
-- Column types are simplified. For physical deployment, use
-- 03_physical_data_model.sql

-- ── CORE HEALTH ENTITIES ────────────────────────────────────

-- Central entity: the patient
CREATE TABLE PATIENT (
    patient_id          VARCHAR(50),  -- NHS Number or local identifier
    nhs_number          VARCHAR(10),  -- Verified NHS Number
    local_patient_id    VARCHAR(50),  -- Local MRN / PAS number
    date_of_birth       DATE,
    sex                 VARCHAR(10),
    gender_identity     VARCHAR(50),
    ethnicity_code      VARCHAR(10),
    postcode_sector     VARCHAR(5),   -- Partial postcode only (anonymisation)
    date_registered     DATE,
    is_deceased         BOOLEAN,
    date_of_death       DATE
);
COMMENT ON TABLE PATIENT IS 'Central patient entity. One record per unique patient. NHS Number is the primary enterprise key.';

-- Organisation (Trust, ICB, GP Practice, etc.)
CREATE TABLE ORGANISATION (
    org_id              VARCHAR(20),   -- ODS Code
    ods_code            VARCHAR(10),   -- NHS ODS Code
    org_name            VARCHAR(200),
    org_type            VARCHAR(50),   -- TRUST / ICB / GP_PRACTICE / NHSE / LA
    parent_org_id       VARCHAR(20),
    region_code         VARCHAR(10),
    is_active           BOOLEAN
);
COMMENT ON TABLE ORGANISATION IS 'NHS and partner organisations. ODS Code is the enterprise key per NHS Data Standards.';

-- Clinical Event (encounter / appointment / admission)
CREATE TABLE CLINICAL_EVENT (
    event_id            VARCHAR(50),
    patient_id          VARCHAR(50),   -- FK → PATIENT
    org_id              VARCHAR(20),   -- FK → ORGANISATION
    practitioner_id     VARCHAR(50),   -- FK → PRACTITIONER
    event_type          VARCHAR(50),   -- INPATIENT / OUTPATIENT / A&E / COMMUNITY
    event_date          TIMESTAMP,
    discharge_date      TIMESTAMP,
    admission_method    VARCHAR(20),   -- ELECTIVE / EMERGENCY / MATERNITY
    discharge_method    VARCHAR(20),
    specialty_code      VARCHAR(10),   -- NHS national specialty code
    primary_diagnosis   VARCHAR(10),   -- ICD-10 code
    secondary_diagnoses TEXT,          -- Comma-separated ICD-10 codes
    hrg_code            VARCHAR(10),   -- Healthcare Resource Group
    source_system       VARCHAR(50)    -- PAS / EPR / A&E system name
);
COMMENT ON TABLE CLINICAL_EVENT IS 'Hospital episodes and clinical encounters. Maps to SUS (Secondary Uses Service) submission.';

-- Referral
CREATE TABLE REFERRAL (
    referral_id         VARCHAR(50),
    patient_id          VARCHAR(50),   -- FK → PATIENT
    referring_org_id    VARCHAR(20),   -- FK → ORGANISATION (GP / source)
    receiving_org_id    VARCHAR(20),   -- FK → ORGANISATION (Trust / clinic)
    referral_date       DATE,
    referral_type       VARCHAR(30),   -- ROUTINE / URGENT / 2WW / INTERNAL
    specialty_code      VARCHAR(10),
    status              VARCHAR(20),   -- RECEIVED / BOOKED / ATTENDED / DNA / CANCELLED
    first_appointment   DATE,
    rtt_start_date      DATE,          -- RTT (Referral to Treatment) clock start
    rtt_stop_date       DATE,
    pathway_weeks       INTEGER,
    ubrn                VARCHAR(20)    -- Unique Booking Reference Number (e-RS)
);
COMMENT ON TABLE REFERRAL IS 'Patient referrals. Supports RTT pathway monitoring and e-Referral Service (e-RS) reporting.';

-- Sample / Specimen (Pathology / LIMS)
CREATE TABLE SPECIMEN (
    specimen_id         VARCHAR(50),
    patient_id          VARCHAR(50),   -- FK → PATIENT
    event_id            VARCHAR(50),   -- FK → CLINICAL_EVENT
    specimen_type       VARCHAR(50),   -- BLOOD / URINE / SWAB / TISSUE
    collection_date     TIMESTAMP,
    collection_site     VARCHAR(100),
    requesting_org_id   VARCHAR(20),   -- FK → ORGANISATION
    processing_lab_id   VARCHAR(20),   -- FK → ORGANISATION
    snomed_concept      VARCHAR(20),   -- SNOMED CT concept for specimen type
    storage_location    VARCHAR(100),
    disposal_date       DATE
);
COMMENT ON TABLE SPECIMEN IS 'Biological specimens collected from patients. SNOMED CT coded.';

-- Laboratory Result
CREATE TABLE LAB_RESULT (
    result_id           VARCHAR(50),
    specimen_id         VARCHAR(50),   -- FK → SPECIMEN
    patient_id          VARCHAR(50),   -- FK → PATIENT
    test_code           VARCHAR(30),   -- SNOMED / LOINC test code
    test_name           VARCHAR(200),
    result_value        VARCHAR(200),  -- String to accommodate text + numeric
    result_unit         VARCHAR(50),
    reference_range_low DECIMAL(10,4),
    reference_range_high DECIMAL(10,4),
    result_status       VARCHAR(20),   -- PRELIMINARY / FINAL / CORRECTED
    reported_date       TIMESTAMP,
    requesting_clinician VARCHAR(50),  -- FK → PRACTITIONER
    is_critical_value   BOOLEAN
);
COMMENT ON TABLE LAB_RESULT IS 'Laboratory test results. Linked to specimen and patient. SNOMED CT / LOINC coded.';

-- Practitioner
CREATE TABLE PRACTITIONER (
    practitioner_id     VARCHAR(50),
    gmc_number          VARCHAR(10),   -- GMC / NMC / HCPC registration
    gmc_type            VARCHAR(10),   -- DOCTOR / NURSE / AHP etc.
    forename            VARCHAR(100),
    surname             VARCHAR(100),
    primary_specialty   VARCHAR(10),   -- NHS specialty code
    primary_org_id      VARCHAR(20),   -- FK → ORGANISATION
    is_active           BOOLEAN
);
COMMENT ON TABLE PRACTITIONER IS 'Clinical and non-clinical staff. GMC/NMC registration as enterprise key.';

-- Medication / Prescription
CREATE TABLE MEDICATION (
    medication_id       VARCHAR(50),
    patient_id          VARCHAR(50),   -- FK → PATIENT
    event_id            VARCHAR(50),   -- FK → CLINICAL_EVENT
    prescriber_id       VARCHAR(50),   -- FK → PRACTITIONER
    dm_plus_d_code      VARCHAR(20),   -- NHS dm+d code (mandatory for EPS)
    medication_name     VARCHAR(200),
    dose                VARCHAR(100),
    route               VARCHAR(50),   -- ORAL / IV / SC / IM
    frequency           VARCHAR(50),
    start_date          DATE,
    end_date            DATE,
    prescription_type   VARCHAR(30),   -- ACUTE / REPEAT / EPS
    dispenser_org_id    VARCHAR(20)    -- FK → ORGANISATION
);
COMMENT ON TABLE MEDICATION IS 'Medications and prescriptions. dm+d coded per NHS Electronic Prescribing Service standards.';

-- Data Asset (for Data Catalogue / Governance)
CREATE TABLE DATA_ASSET (
    asset_id            VARCHAR(50),
    asset_name          VARCHAR(200),
    asset_type          VARCHAR(50),   -- TABLE / FILE / API / REPORT / DATASET
    source_system       VARCHAR(100),
    data_owner_org_id   VARCHAR(20),   -- FK → ORGANISATION
    data_steward        VARCHAR(100),
    classification      VARCHAR(30),   -- OFFICIAL / OFFICIAL-SENSITIVE / SECRET
    sensitivity         VARCHAR(30),   -- PERSONAL / PSEUDONYMISED / ANONYMISED
    contains_pii        BOOLEAN,
    retention_years     INTEGER,       -- Per NHS Records Management Code of Practice
    last_reviewed_date  DATE,
    data_standard       VARCHAR(100),  -- FHIR / HL7v2 / SNOMED / ICD-10 / OPCS-4
    aws_location        VARCHAR(500),  -- S3 path / RDS endpoint
    is_active           BOOLEAN
);
COMMENT ON TABLE DATA_ASSET IS 'Data catalogue entry. One row per data asset identified during discovery.';
