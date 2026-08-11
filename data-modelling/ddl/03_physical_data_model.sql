-- ============================================================
--  Gov Health Data Discovery Template
--  File: 03_physical_data_model.sql
--  Purpose: Production-ready physical DDL for AWS RDS PostgreSQL
--           Silver Layer — Conformed, Standardised Health Data
--
--  How to use:
--    1. Generate this from Erwin: Actions → Generate Database Schema
--    2. Run against AWS RDS PostgreSQL 15+ instance
--    3. Or import into Erwin to view/edit physical model
--
--  Standards applied:
--    - NHS Data Dictionary field names where applicable
--    - SNOMED CT, ICD-10, OPCS-4, dm+d coding
--    - FHIR R4 alignment for key entities
--    - ICO / UK GDPR data minimisation principles
--
--  Author: [Your Name] | [Engagement Name]
-- ============================================================

-- ── EXTENSIONS ───────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── SCHEMAS ──────────────────────────────────────────────────
CREATE SCHEMA IF NOT EXISTS silver;     -- Conformed / cleansed data
CREATE SCHEMA IF NOT EXISTS gold;       -- Analytics-ready aggregations
CREATE SCHEMA IF NOT EXISTS governance; -- Data catalogue and audit

SET search_path = silver, public;

-- ── DROP EXISTING (safe re-run) ──────────────────────────────
DROP TABLE IF EXISTS silver.lab_result          CASCADE;
DROP TABLE IF EXISTS silver.medication          CASCADE;
DROP TABLE IF EXISTS silver.specimen            CASCADE;
DROP TABLE IF EXISTS silver.referral            CASCADE;
DROP TABLE IF EXISTS silver.clinical_event      CASCADE;
DROP TABLE IF EXISTS silver.practitioner        CASCADE;
DROP TABLE IF EXISTS silver.organisation        CASCADE;
DROP TABLE IF EXISTS silver.patient             CASCADE;
DROP TABLE IF EXISTS governance.data_asset      CASCADE;
DROP TABLE IF EXISTS governance.audit_log       CASCADE;
DROP TABLE IF EXISTS governance.data_quality_log CASCADE;

-- ══ DIMENSION TABLES ═════════════════════════════════════════

-- ── PATIENT ──────────────────────────────────────────────────
CREATE TABLE silver.patient (
    patient_sk          UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    nhs_number          CHAR(10)        NOT NULL,              -- Verified NHS Number (NHS DD: NHS_NUMBER)
    local_patient_id    VARCHAR(20),                           -- MRN / PAS local ID
    date_of_birth       DATE            NOT NULL,
    age_band            VARCHAR(10)     GENERATED ALWAYS AS (
                            CASE
                                WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) BETWEEN 0  AND 4  THEN '0-4'
                                WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) BETWEEN 5  AND 17 THEN '5-17'
                                WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) BETWEEN 18 AND 29 THEN '18-29'
                                WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) BETWEEN 30 AND 49 THEN '30-49'
                                WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) BETWEEN 50 AND 64 THEN '50-64'
                                WHEN EXTRACT(YEAR FROM AGE(date_of_birth)) BETWEEN 65 AND 79 THEN '65-79'
                                ELSE '80+'
                            END
                        ) STORED,
    sex                 CHAR(1)         NOT NULL CHECK (sex IN ('M','F','I','U')),  -- NHS DD: SEX
    gender_identity     VARCHAR(50),
    ethnicity_code      VARCHAR(5),    -- NHS 2001 Ethnicity Classification
    postcode_sector     VARCHAR(5),    -- First 5 chars only (IG: do not store full postcode)
    gp_practice_ods     VARCHAR(10),   -- GP Practice ODS code
    registered_gp_ods   VARCHAR(10),
    is_deceased         BOOLEAN         NOT NULL DEFAULT FALSE,
    date_of_death       DATE,
    data_source         VARCHAR(50)     NOT NULL,
    source_patient_id   VARCHAR(50),   -- Original ID in source system
    load_date           TIMESTAMP       NOT NULL DEFAULT NOW(),
    last_updated        TIMESTAMP       NOT NULL DEFAULT NOW(),
    is_current          BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_nhs_number UNIQUE (nhs_number)
);

COMMENT ON TABLE silver.patient IS 'Conformed patient dimension. NHS Number is business key. Full postcode excluded per IG policy.';
COMMENT ON COLUMN silver.patient.nhs_number IS 'NHS Number — 10 digit, verified. NHS Data Dictionary: NHS_NUMBER';
COMMENT ON COLUMN silver.patient.ethnicity_code IS 'NHS 2001 Ethnic Category Code. Ref: https://www.datadictionary.nhs.uk/';

-- ── ORGANISATION ─────────────────────────────────────────────
CREATE TABLE silver.organisation (
    org_sk              UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    ods_code            VARCHAR(10)     NOT NULL UNIQUE,   -- ODS Code (mandatory NHS identifier)
    org_name            VARCHAR(255)    NOT NULL,
    org_type            VARCHAR(30)     NOT NULL
                        CHECK (org_type IN ('TRUST','ICB','GP_PRACTICE','NHSE','LOCAL_AUTHORITY','PRIVATE','LAB','OTHER')),
    parent_ods_code     VARCHAR(10),
    commissioning_region VARCHAR(10),
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    ods_last_updated    DATE,
    load_date           TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE silver.organisation IS 'NHS and partner organisations. ODS Code from NHS Digital Organisation Data Service.';

-- ── PRACTITIONER ─────────────────────────────────────────────
CREATE TABLE silver.practitioner (
    practitioner_sk     UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    registration_number VARCHAR(20)     NOT NULL,   -- GMC / NMC / HCPC
    registration_body   VARCHAR(10)     CHECK (registration_body IN ('GMC','NMC','HCPC','GDC','GPhC','OTHER')),
    forename            VARCHAR(100),
    surname             VARCHAR(100),
    primary_specialty   VARCHAR(10),    -- NHS national specialty code
    grade               VARCHAR(50),    -- CONSULTANT / REGISTRAR / SHO / NURSE / AHP
    primary_org_sk      UUID            REFERENCES silver.organisation(org_sk),
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    load_date           TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ══ FACT TABLES ══════════════════════════════════════════════

-- ── CLINICAL_EVENT (Hospital Episode) ────────────────────────
CREATE TABLE silver.clinical_event (
    event_sk            UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_id            VARCHAR(100)    NOT NULL,   -- Source system event ID
    patient_sk          UUID            NOT NULL REFERENCES silver.patient(patient_sk),
    org_sk              UUID            NOT NULL REFERENCES silver.organisation(org_sk),
    practitioner_sk     UUID            REFERENCES silver.practitioner(practitioner_sk),
    event_type          VARCHAR(20)     NOT NULL
                        CHECK (event_type IN ('INPATIENT','DAYCASE','OUTPATIENT','A_AND_E','COMMUNITY','MENTAL_HEALTH')),
    admission_date      DATE,
    discharge_date      DATE,
    length_of_stay_days INTEGER         GENERATED ALWAYS AS (
                            CASE WHEN discharge_date IS NOT NULL AND admission_date IS NOT NULL
                                 THEN (discharge_date - admission_date)
                                 ELSE NULL
                            END
                        ) STORED,
    admission_method    VARCHAR(5),     -- NHS DD: ADMISSION_METHOD (11=Elective, 21=Emergency)
    discharge_method    VARCHAR(5),     -- NHS DD: DISCHARGE_METHOD
    specialty_code      VARCHAR(10),    -- National specialty code
    primary_diagnosis   VARCHAR(10),    -- ICD-10 code (4-char)
    secondary_diag_1    VARCHAR(10),    -- ICD-10
    secondary_diag_2    VARCHAR(10),    -- ICD-10
    secondary_diag_3    VARCHAR(10),    -- ICD-10
    primary_procedure   VARCHAR(10),    -- OPCS-4 code
    hrg_code            VARCHAR(10),    -- HRG (Healthcare Resource Group)
    spell_number        VARCHAR(50),
    sus_submission_date DATE,
    source_system       VARCHAR(50)     NOT NULL,
    load_date           TIMESTAMP       NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_event UNIQUE (event_id, source_system)
);

COMMENT ON TABLE silver.clinical_event IS 'Hospital episodes and clinical encounters. Aligned to SUS HES (Hospital Episode Statistics) schema.';

-- ── REFERRAL ─────────────────────────────────────────────────
CREATE TABLE silver.referral (
    referral_sk         UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    referral_id         VARCHAR(100)    NOT NULL,
    patient_sk          UUID            NOT NULL REFERENCES silver.patient(patient_sk),
    referring_org_sk    UUID            REFERENCES silver.organisation(org_sk),
    receiving_org_sk    UUID            REFERENCES silver.organisation(org_sk),
    referral_date       DATE            NOT NULL,
    referral_type       VARCHAR(20)
                        CHECK (referral_type IN ('ROUTINE','URGENT','TWO_WEEK_WAIT','SELF','INTERNAL','CHOOSE_AND_BOOK')),
    specialty_code      VARCHAR(10),
    status              VARCHAR(20)
                        CHECK (status IN ('RECEIVED','TRIAGED','BOOKED','ATTENDED','DNA','CANCELLED','REJECTED')),
    first_appointment   DATE,
    rtt_start_date      DATE,           -- RTT clock start
    rtt_stop_date       DATE,           -- RTT clock stop
    rtt_weeks_elapsed   INTEGER         GENERATED ALWAYS AS (
                            CASE WHEN rtt_stop_date IS NOT NULL
                                 THEN EXTRACT(WEEK FROM AGE(rtt_stop_date, rtt_start_date))::INTEGER
                                 ELSE EXTRACT(WEEK FROM AGE(CURRENT_DATE, rtt_start_date))::INTEGER
                            END
                        ) STORED,
    breach_flag         BOOLEAN         GENERATED ALWAYS AS (
                            CASE WHEN rtt_start_date IS NOT NULL
                                 THEN EXTRACT(WEEK FROM AGE(COALESCE(rtt_stop_date, CURRENT_DATE), rtt_start_date)) > 18
                                 ELSE FALSE
                            END
                        ) STORED,
    ubrn                VARCHAR(20),    -- Unique Booking Reference Number (e-RS)
    source_system       VARCHAR(50)     NOT NULL,
    load_date           TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE silver.referral IS 'Patient referrals with RTT pathway tracking. 18-week breach flag auto-calculated.';

-- ── SPECIMEN ─────────────────────────────────────────────────
CREATE TABLE silver.specimen (
    specimen_sk         UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    specimen_id         VARCHAR(100)    NOT NULL,
    patient_sk          UUID            NOT NULL REFERENCES silver.patient(patient_sk),
    event_sk            UUID            REFERENCES silver.clinical_event(event_sk),
    specimen_type       VARCHAR(50),
    snomed_concept      VARCHAR(20),    -- SNOMED CT concept ID
    collection_date     TIMESTAMP       NOT NULL,
    requesting_org_sk   UUID            REFERENCES silver.organisation(org_sk),
    processing_lab_sk   UUID            REFERENCES silver.organisation(org_sk),
    disposal_date       DATE,
    source_system       VARCHAR(50)     NOT NULL,
    load_date           TIMESTAMP       NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_specimen UNIQUE (specimen_id, source_system)
);

-- ── LAB_RESULT ───────────────────────────────────────────────
CREATE TABLE silver.lab_result (
    result_sk           UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    result_id           VARCHAR(100)    NOT NULL,
    specimen_sk         UUID            NOT NULL REFERENCES silver.specimen(specimen_sk),
    patient_sk          UUID            NOT NULL REFERENCES silver.patient(patient_sk),
    test_code           VARCHAR(30),    -- SNOMED CT / LOINC code
    test_name           VARCHAR(255),
    result_value_text   VARCHAR(500),
    result_value_num    NUMERIC(12,4),
    result_unit         VARCHAR(50),
    ref_range_low       NUMERIC(10,4),
    ref_range_high      NUMERIC(10,4),
    result_status       VARCHAR(15)
                        CHECK (result_status IN ('PRELIMINARY','FINAL','CORRECTED','CANCELLED','AMENDED')),
    is_abnormal         BOOLEAN,
    is_critical_value   BOOLEAN         NOT NULL DEFAULT FALSE,
    reported_date       TIMESTAMP       NOT NULL,
    requesting_clinician_sk UUID        REFERENCES silver.practitioner(practitioner_sk),
    source_system       VARCHAR(50)     NOT NULL,
    load_date           TIMESTAMP       NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_result UNIQUE (result_id, source_system)
);

-- ── MEDICATION ───────────────────────────────────────────────
CREATE TABLE silver.medication (
    medication_sk       UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    medication_id       VARCHAR(100)    NOT NULL,
    patient_sk          UUID            NOT NULL REFERENCES silver.patient(patient_sk),
    event_sk            UUID            REFERENCES silver.clinical_event(event_sk),
    prescriber_sk       UUID            REFERENCES silver.practitioner(practitioner_sk),
    dm_plus_d_code      VARCHAR(20),    -- NHS dm+d VMPP/VMP code
    medication_name     VARCHAR(255),
    dose_text           VARCHAR(200),
    dose_amount         NUMERIC(10,4),
    dose_unit           VARCHAR(30),
    route               VARCHAR(30)
                        CHECK (route IN ('ORAL','IV','IM','SC','TOPICAL','INHALED','NASAL','OCULAR','OTHER')),
    frequency           VARCHAR(50),
    start_date          DATE,
    end_date            DATE,
    prescription_type   VARCHAR(20)
                        CHECK (prescription_type IN ('ACUTE','REPEAT','REPEAT_DISPENSING','EPS','OTC')),
    eps_prescription_id VARCHAR(50),    -- Electronic Prescription Service ID
    dispenser_org_sk    UUID            REFERENCES silver.organisation(org_sk),
    source_system       VARCHAR(50)     NOT NULL,
    load_date           TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ══ GOVERNANCE TABLES ════════════════════════════════════════

-- ── DATA ASSET (Catalogue) ───────────────────────────────────
CREATE TABLE governance.data_asset (
    asset_sk            UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    asset_name          VARCHAR(255)    NOT NULL,
    asset_type          VARCHAR(30)
                        CHECK (asset_type IN ('TABLE','VIEW','FILE','API','REPORT','DATASET','PIPELINE')),
    description         TEXT,
    source_system       VARCHAR(100),
    owner_org_sk        UUID            REFERENCES silver.organisation(org_sk),
    data_steward        VARCHAR(150),
    data_owner          VARCHAR(150),
    classification      VARCHAR(30)     NOT NULL
                        CHECK (classification IN ('OFFICIAL','OFFICIAL-SENSITIVE','SECRET','TOP-SECRET')),
    sensitivity         VARCHAR(30)
                        CHECK (sensitivity IN ('PERSONAL','PSEUDONYMISED','ANONYMISED','NON-PERSONAL')),
    contains_pii        BOOLEAN         NOT NULL DEFAULT FALSE,
    legal_basis         VARCHAR(100),   -- UK GDPR Article 6/9 basis
    retention_years     SMALLINT,       -- Per NHS Records Management Code of Practice 2021
    review_date         DATE,
    aws_location        VARCHAR(1000),  -- S3 URI / RDS endpoint
    data_standard       VARCHAR(100),   -- FHIR / HL7v2 / SNOMED / ICD-10
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE governance.data_asset IS 'Data catalogue. One entry per data asset discovered. Supports IG compliance and Purview integration.';

-- ── AUDIT LOG ────────────────────────────────────────────────
CREATE TABLE governance.audit_log (
    log_id              UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_timestamp     TIMESTAMP       NOT NULL DEFAULT NOW(),
    event_type          VARCHAR(50)     NOT NULL,  -- INSERT / UPDATE / DELETE / EXPORT / ACCESS
    table_name          VARCHAR(100),
    record_id           VARCHAR(100),
    changed_by          VARCHAR(100),
    change_description  TEXT,
    source_ip           VARCHAR(45),
    session_id          VARCHAR(100)
);

-- ── DATA QUALITY LOG ─────────────────────────────────────────
CREATE TABLE governance.data_quality_log (
    dq_log_id           UUID            DEFAULT uuid_generate_v4() PRIMARY KEY,
    check_date          TIMESTAMP       NOT NULL DEFAULT NOW(),
    asset_sk            UUID            REFERENCES governance.data_asset(asset_sk),
    dimension           VARCHAR(20)
                        CHECK (dimension IN ('COMPLETENESS','ACCURACY','CONSISTENCY','TIMELINESS','UNIQUENESS','VALIDITY')),
    table_name          VARCHAR(100),
    column_name         VARCHAR(100),
    total_records       INTEGER,
    failing_records     INTEGER,
    score_pct           NUMERIC(5,2),
    threshold_pct       NUMERIC(5,2),
    passed              BOOLEAN,
    notes               TEXT
);

-- ══ INDEXES ══════════════════════════════════════════════════
CREATE INDEX idx_patient_nhs         ON silver.patient(nhs_number);
CREATE INDEX idx_patient_dob         ON silver.patient(date_of_birth);
CREATE INDEX idx_org_ods             ON silver.organisation(ods_code);
CREATE INDEX idx_event_patient       ON silver.clinical_event(patient_sk);
CREATE INDEX idx_event_org           ON silver.clinical_event(org_sk);
CREATE INDEX idx_event_admission     ON silver.clinical_event(admission_date);
CREATE INDEX idx_event_specialty     ON silver.clinical_event(specialty_code);
CREATE INDEX idx_referral_patient    ON silver.referral(patient_sk);
CREATE INDEX idx_referral_rtt_start  ON silver.referral(rtt_start_date);
CREATE INDEX idx_referral_breach     ON silver.referral(breach_flag) WHERE breach_flag = TRUE;
CREATE INDEX idx_specimen_patient    ON silver.specimen(patient_sk);
CREATE INDEX idx_result_patient      ON silver.lab_result(patient_sk);
CREATE INDEX idx_result_critical     ON silver.lab_result(is_critical_value) WHERE is_critical_value = TRUE;
CREATE INDEX idx_result_reported     ON silver.lab_result(reported_date);
CREATE INDEX idx_med_patient         ON silver.medication(patient_sk);
CREATE INDEX idx_asset_class         ON governance.data_asset(classification);
CREATE INDEX idx_dq_asset            ON governance.data_quality_log(asset_sk);
